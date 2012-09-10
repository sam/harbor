class <@= app_class @>
  class Users < Harbor::Controller

    get "new" do
      @ex_form = ExampleForm.new
      render "new"
    end

    post "new" do
      # Validate
      @ex_form = ExampleForm.new(request.params)
      if @ex_form.valid?
        # Save would probably occur here
        render "success"
      else
        render "edit"
      end
    end

    get "edit" do
      @ex_form = ExampleForm.new({first_name: 'James', age: 21})
      render "edit"
    end

    post "edit" do
      @ex_form = ExampleForm.new(request.params)
      if @ex_form.valid?
        render "/users/success"
      else
        render "edit"
      end
    end
  end
end
