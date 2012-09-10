class Harbor
  class Request

    include_package "javax.servlet.http"
    
    attr_accessor :layout
    
    def initialize(http_request)
      unless http_request.is_a?(HttpServletRequest)
        raise ArgumentError.new("+http_request+ must be a HttpServletRequest")
      end
      
      @http_request = http_request
    end
    
    ## BEGIN: Forwarded methods
    
    def scheme
      @http_request.scheme
    end
    
    ## END: Forwarded methods

    class Headers
      def initialize(http_request)
        @http_request = http_request
      end
      
      def [](name)
        values = @http_request.headers(name)
        
        if values.blank?
          nil
        elsif values.size > 1
          values
        else
          values[0]
        end
      end
    end
    
    def headers
      @headers ||= Headers.new(@http_request)    
    end
    
    class Cookies
      def initialize(http_request)
        @http_request = http_request
      end
      
      def [](name)
        cookies.detect { |cookie| cookie.name == name }
      end
      
      private
      
      def cookies
        @cookies ||= @http_request.cookies
      end
    end
    
    def cookies
      @cookies ||= Cookies.new(@http_request)
    end
    
    def fetch(key, default_value = nil)
      if (value = self[key]).nil? || value == ''
        default_value
      else
        value
      end
    end

    def bot?
      user_agent = env["HTTP_USER_AGENT"]
      BOT_AGENTS.any? { |bot_agent| user_agent =~ bot_agent }
    end

    def remote_ip
      # handling proxied environments
      env["HTTP_X_FORWARDED_FOR"] || env["HTTP_CLIENT_IP"] || env["REMOTE_ADDR"]
    end

    def request_method
      @env['REQUEST_METHOD'] = self.POST['_method'].upcase if request_method_in_params?
      @env['REQUEST_METHOD']
    end

    def health_check?
      !params["health_check"].nil?
    end

    def params
      {}
    end
    
    def session
      @http_request.session
    end

    def protocol
      ssl? ? 'https://' : 'http://'
    end

    def ssl?
      @env['HTTPS'] == 'on' || @env['HTTP_X_FORWARDED_PROTO'] == 'https'
    end

    def referer
      @env['HTTP_REFERER']
    end

    def uri
      @env['REQUEST_URI'] || @env['REQUEST_PATH'] || @env['PATH_INFO']
    end

    def messages
      @messages ||= session[:messages] = Messages.new(session[:messages])
    end

    def message(key)
      messages[key]
    end

    # ==== Returns
    # String::
    #   The URI without the query string. Strips trailing "/" and reduces
    #   duplicate "/" to a single "/".
    def path
      path = (uri.empty? ? '/' : uri.split('?').first).squeeze("/")
      path = path[0..-2] if (path[-1] == ?/) && path.size > 1
      path
    end

    def accept
      @accept ||= begin
        entries = @env['HTTP_ACCEPT'].to_s.split(',')
        entries.map! { |e| accept_entry(e) }
        entries.sort_by! { |e| [e.last, entries.index(e)] }
        entries.map(&:first)
      end
    end

    def preferred_type(*types)
      return accept.first if types.empty?
      types.flatten!
      accept.detect do |pattern|
        type = types.detect { |t| ::File.fnmatch(pattern, t) }
        return type if type
      end
    end

    # Returns the extension for the format used in the request.
    #
    # GET /posts/5.xml | request.format => xml
    # GET /posts/5.js | request.format => js
    # GET /posts/5 | request.format => request.accepts.first
    #
    def format
      formats.first
    end

    def format=(format)
      params['format'] = format
      @formats = [format]
    end

    BROWSER_LIKE_ACCEPTS = /,\s*\*\/\*|\*\/\*\s*,/

    def formats
      @formats ||= begin
        http_accept = @env['HTTP_ACCEPT']

        accepted_formats = if params['format']
          Array(params['format'])
        elsif xhr? || (http_accept && http_accept !~ BROWSER_LIKE_ACCEPTS)
          # TODO: Mime types could be objects
          accept.map{|type| Mime.extension(type).to_s.gsub(/^\./, '')}
        else
          ['html']
        end

        accepted_formats == ['all'] ? ['html'] : accepted_formats
      end
    end
    
    def xhr?
      @http_request.header("HTTP_X_REQUESTED_WITH") == "XMLHttpRequest"
    end

    # Returns the data received in the request body.
    #
    # This method support both application/x-www-form-urlencoded and
    # multipart/form-data.
    def POST
      if @env["rack.input"].nil?
        raise "Missing rack.input"
      elsif @env["rack.request.form_input"].eql? @env["rack.input"]
        @env["rack.request.form_hash"]
      elsif form_data? || parseable_data?
        @env["rack.request.form_input"] = @env["rack.input"]
        unless @env["rack.request.form_hash"] = parse_multipart(env)
          form_vars = @env["rack.input"].read
    
          # Fix for Safari Ajax postings that always append \0
          # form_vars.sub!(/\0\z/, '') # performance replacement:
          form_vars.slice!(-1) if form_vars[-1] == ?\0
    
          @env["rack.request.form_vars"] = form_vars
          @env["rack.request.form_hash"] = parse_query(form_vars)
    
          @env["rack.input"].rewind
        end
        @env["rack.request.form_hash"]
      else
        {}
      end
    end
    
    private

    def accept_entry(entry)
      type, *options = entry.delete(' ').split(';')
      quality = 0 # we sort smallest first
      options.delete_if { |e| quality = 1 - e[2..-1].to_f if e.start_with? 'q=' }
      [type, [quality, type.count('*'), 1 - options.size]]
    end

    def request_method_in_params?
      @env["REQUEST_METHOD"] == "POST" && self.POST && %w(PUT DELETE).include?((self.POST['_method'] || "").upcase)
    end
    
  end
end
