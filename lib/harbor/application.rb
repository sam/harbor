rack = if RUBY_PLATFORM =~ /java/
  "jruby-rack"
else
  "rack"
end

begin
  require rack
rescue LoadError
  puts "   #{rack} gem is not available, please add it to you Gemfile and run bundle"
  exit(1)
end

require "yaml"

require_relative "events"
require_relative "request"
require_relative "response"
require_relative "block_io"
require_relative "events/dispatch_request_event"
require_relative "events/not_found_event"
require_relative "events/application_exception_event"
require_relative "events/session_created_event_context"
require_relative "event_context"
require_relative "messages"

module Harbor
  class Application

    include Harbor::Events

    ##
    # Request entry point called by Rack. It creates a request and response
    # object based on the incoming request environment, checks for public
    # files, and dispatches the request.
    #
    # It returns a rack response hash.
    ##
    def call(env)
      warn "DEPRECATED: Application#call"
      
      request = Request.new(self, env)
      response = Response.new(request)

      catch(:abort_request) do
        handler = router.match(request)
        dispatch_request(handler, request, response)
      end

      response.to_a
    end

    ##
    # Request dispatch function, which handles 404's, exceptions,
    # and logs requests.
    ##
    def dispatch_request(handler, request, response)
      warn "DEPRECATED: Application#call"
      
      dispatch_request_event = Events::DispatchRequestEvent.new(request, response)
      raise_event(:request_dispatch, dispatch_request_event)

      return handle_not_found(request, response) unless handler

      handler.call(request, response)
    rescue StandardError, LoadError, SyntaxError => e
      handle_exception(e, request, response)
    ensure
      raise_event(:request_complete, dispatch_request_event.complete!)
    end

    ##
    # Method used to nicely handle cases where no routes or public files
    # match the incoming request.
    #
    # By default, it will render "The page you requested could not be found".
    #
    # To use a custom 404 message, create a view "exceptions/404.html.erb", and
    # optionally create a view "layouts/exception.html.erb" to style it.
    ##
    def handle_not_found(request, response)
      warn "DEPRECATED: Application#call"
      
      response.flush
      response.status = 404

      response.layout = "layouts/exception" if Harbor::View.exists?("layouts/exception")

      if Harbor::View.exists?("exceptions/404.html.erb")
        response.render "exceptions/404.html.erb"
      else
        response.puts "The page you requested could not be found"
      end

      raise_event(:not_found, Events::NotFoundEvent.new(request, response))
    end

    ##
    # Method used to nicely handle uncaught exceptions.
    #
    # Logs full error messages to the configured 'error' logger.
    #
    # By default, it will render "We're sorry, but something went wrong."
    #
    # To use a custom 500 message, create a view "exceptions/500.html.erb", and
    # optionally create a view "layouts/exception.html.erb" to style it.
    ##
    def handle_exception(exception, request, response)
      warn "DEPRECATED: Application#call"
      
      response.flush
      response.status = 500

      if config.development?
        response.content_type = "text/html"
        response.puts(Rack::ShowExceptions.new(nil).pretty(request.env, exception))
      else
        response.layout = "layouts/exception" if Harbor::View.exists?("layouts/exception")

        if Harbor::View.exists?("exceptions/500.html.erb")
          response.render "exceptions/500.html.erb", :exception => exception
        else
          response.puts "We're sorry, but something went wrong."
        end
      end

      raise_event(:exception, ApplicationExceptionEvent.new(request, response, exception))

      nil
    end
  end
end
