class Ht
  class Home < Harbor::Controller

    get "/" do
      @ex_form = ExampleForm.new(request, response)
      render "home/index"
    end

  end
end
