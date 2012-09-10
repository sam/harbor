class Harbor
  class Test
    
    def self.request(uri = "/", headers = {}, session = {}, cookies = {})
      Harbor::Request.new(HttpRequest.new(uri, headers, session, cookies))  
    end
    
    class HttpRequest
  
      include javax.servlet.http.HttpServletRequest
  
      def initialize(uri, headers, session, cookies)
        @uri = java.net.URI.new(uri)
        @headers = headers
        @session = session
        @cookies = cookies
      end
  
      def scheme
        @uri.scheme
      end
      
      def header(name)
        headers(name)
      end
  
      def headers(name)
        @headers[name]
      end
  
      def cookies
        @cookies
      end
  
      def session
        @session
      end
  
      def messages
        @messages
      end
    end
  end
end