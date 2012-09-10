require "rubygems"
require "bundler/setup" unless Object::const_defined?("Bundler")

if ENV['COVERAGE']
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
  end
end

require "minitest/autorun"
require "minitest/pride"
require "minitest/wscolor"

$:.unshift (Pathname(__FILE__).dirname.parent + "lib").to_s
require "harbor"

require_relative "helpers/time"
require_relative "helpers/string"
require_relative "helpers/test/request"

class MiniTest::Unit::TestCase

  def capture_stderr(&block)
    $stderr = StringIO.new

    yield

    result = $stderr.string
    $stderr = STDERR

    result
  end

  def assert_route_matches(http_method, path)
    action = Harbor::Router::instance.match(http_method, path).action
    refute_nil(action, "Expected router match for #{http_method}:#{path}, got nil.")

    yield(action) if block_given?
  end

  def assert_controller_route_matches(http_method, path, controller, method_name)
    action = Harbor::Router::instance.match(http_method, path).action

    assert_kind_of(Harbor::Controller::Action, action)
    assert_equal(controller, action.controller)
    assert_equal(method_name, action.name)
  end

end

def upload(filename)
  input = <<-EOF
--AaB03x\r
Content-Disposition: form-data; name="file"; filename="#{filename}"\r
Content-Type: image/jpeg\r
\r
#{File.read(Pathname(__FILE__).dirname + "fixtures/samples" + filename)}\r
\r
--AaB03x\r
Content-Disposition: form-data; name="video[caption]"\r
\r
test\r
--AaB03x\r
Content-Disposition: form-data; name="video[transcoder][1]"\r
\r
on\r
--AaB03x\r
Content-Disposition: form-data; name="video[transcoder][4]"\r
\r
on\r
--AaB03x\r
Content-Disposition: form-data; name="video[transcoder][5]"\r
\r
on\r
--AaB03x--\r
\r
EOF
  Rack::Request.new Rack::MockRequest.env_for("/",
                    "CONTENT_TYPE" => "multipart/form-data, boundary=AaB03x",
                    "CONTENT_LENGTH" => input.bytesize,
                    :input => input)
end
