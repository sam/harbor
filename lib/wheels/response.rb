require "stringio"
require Pathname(__FILE__).dirname + "view"

class Response < StringIO

  attr_accessor :status, :content_type, :headers

  def initialize
    @headers = {}
    @content_type = "text/html"
    @status = 200
    super("")
  end

  def headers
    @headers.merge({
      "Content-Type" => self.content_type,
      "Content-Length" => self.size.to_s
    })
  end

  def render(view, context = {})
    layout = context.fetch(:layout, "layouts/application.html.erb")

    view = View.new(view, context)
    content_type = view.content_type
    puts view.to_s(layout)
  end

  def inspect
    "<#{self.class} headers=#{headers.inspect} content_type=#{content_type.inspect} status=#{status.inspect} body=#{string.inspect}>"
  end

end