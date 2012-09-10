#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::Request do

  describe "as uri" do
    describe "scheme" do
      it "must return null if the scheme of the request isn't specified" do
        request = Harbor::Test::request("/example")
        request.scheme.must_be_nil
      end
      
      it "must use the scheme of the request if present" do
        request = Harbor::Test::request("https://example.com")
        request.scheme.must_equal "https"
      end
    end
  end

end