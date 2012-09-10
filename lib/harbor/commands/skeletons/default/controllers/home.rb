class <@= app_class @>
  class Home < Harbor::Controller

    get "/" do
      # When the ExampleForm instantiated here is rendered it will look for an
      # example_form.* template under views/forms, and if found it will use
      # that to render the form. This default behavior can be overridden by
      # setting the template for the form, e.g.:
      #
      # @ex_form.template = "another_form_template"

      @ex_form = ExampleForm.new(request.params)
      render "home/index"
    end

    post "/new_user" do
      @ex_form = ExampleForm.new(request.params)
      if @ex_form.valid?
        render "home/success"
      else
        render "home/index"
      end
    end

  end
end
