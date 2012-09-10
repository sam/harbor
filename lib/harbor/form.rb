require 'bureaucrat'
require 'bureaucrat/quickfields'

class Harbor
  class Form < Bureaucrat::Forms::Form
    extend Bureaucrat::Quickfields

    def initialize(params = {})
      @params = params
      super(@params)
    end

    attr_reader :params
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
        return view.content
      end

      "Template '#{name}' not found."
    end

  end
end
