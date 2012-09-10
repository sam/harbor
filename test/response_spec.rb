#!/usr/bin/env jruby

require_relative "helper"

describe Harbor::Response do
  
  describe "redirect" do
    it "must preserve query-string params" do
      request = Harbor::Test::request()
      response = Harbor::Response.new(request)
    
      response.redirect("/redirect?key=Stuff", { "other[thing]" => "value" })
      
      root, query = response.headers["Location"].split(/\?/)
      
      root.must_equal "/redirect"
      query.split(/\&/).sort.must_equal [ "key=Stuff", "other%5Bthing%5D=value" ]
    end
  end
end