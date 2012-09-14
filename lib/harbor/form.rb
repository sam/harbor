require 'bureaucrat'
require 'harbor/form/quickfields'

class Harbor
  # Base form class for Harbor. This class provides the ability to store form
  # data as well as render HTML widgets associated with the form. Implementations
  # look similar to the following:
  #
  #   class UserForm < Harbor::Form
  #     string :first_name
  #     integer :age
  #   end
  #
  # The following field types are supported: string, text, password, integer,
  # decimal, regex, email, file, boolean, null_boolean, choice, typed_choice,
  # multiple_choice, radio_choice, and checkbox_multiple_choice.
  #
  # Fields are required by default. To make a field optional:
  #
  #   email :email1, required: false
  #
  # Typically an instance of the form class will be added to an action. For
  # example:
  #
  #   get "new" do
  #     @user_form = UserForm.new
  #     render "new"
  #   end
  #
  #   post "new" do
  #     @user_form = UserForm.new(request.params)
  #     ...
  #   end
  #
  # This would add the new instance of UserForm to the request, and the
  # @user_form variable would be available to any views that eventually get
  # rendered. Rendering the actual form is a simple matter of including the
  # variable in the file:
  #
  #   <%= @user_form %>
  #
  # This calls .to_s for the form object. By default it will look for the file
  # "views/forms/user_form.html.erb", and if found use that to display the form.
  # This behavior can be overridden by specifying a template when the form is
  # instantiated:
  #
  #   @user_form = UserForm.new
  #   @user_form.template = "user_form2"
  #
  # Note that the file extension is not provided here. Note also that if the
  # template cannot be found and one is not specified a runtime error will occur.
  # 
  # In the template, rendering individual form elements is a matter of
  # referencing them:
  #
  #   <%= @user_form[:first_name] %>
  #
  # This will render an HTML <input> widget of type text, populating the value
  # attribute with any values in the Harbor::Form object. If you only need access
  # to the value stored in the form, use the .data method:
  #
  #   <%= @user_form[:first_name].data %>
  #
  class Form < Bureaucrat::Forms::Form
    extend Quickfields

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

