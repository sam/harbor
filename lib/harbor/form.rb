require 'bureaucrat'
require 'bureaucrat/quickfields'

class Harbor
  class Form < Bureaucrat::Forms::Form
    extend Bureaucrat::Quickfields

    @@templates = Harbor::TemplateLookup.new(['views/forms'])

    def initialize(request, response)
      @request = request
      @response = response

      name = self.class.name.underscore
      @template = @@templates.find(name) if @@templates.exists?(name)

      super(@request.params)
    end

    attr_reader :request, :response, :template

    def to_s
      if @template
        @response.render(@template)
        return
      end
      # TODO: Render default form view
      @response.puts("Template '#{self.class.name.underscore}' not found.")
    end

  end
end
