require 'bureaucrat'
require 'bureaucrat/quickfields'

class Harbor
  class Form < Bureaucrat::Forms::Form
    extend Bureaucrat::Quickfields

    def initialize(request, response)
      @request = request
      @response = response

      super(@request.params)
    end

    attr_reader :request, :response
    attr_accessor :template

    def errors
      @errors ? @errors : {}
    end

    def valid?
      full_clean
      super
    end

    def to_s
      name = template ? template : self.class.name.underscore
      if Harbor::View.exists?(name)
        view = Harbor::View.new(name, {name.to_sym => self})
        view.context.instance_eval %Q{
          def #{self.class.name.underscore}
            @#{self.class.name.underscore}
          end
        }
        return view.content
      end

      "Template '#{name}' not found."
    end

  end
end
