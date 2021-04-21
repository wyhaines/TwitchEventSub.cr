require "http/server"
require "./server/*"

module TwitchEventSub
  class HttpServer
    def initialize(
      @host : String,
      @port : Int32,
      @context : OpenSSL::SSL::Context::Server? = nil
    )
      @server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
        TwitchEventSub::HttpServer::TwitchHandler.new
      ])
      bind_server
    end

    private def bind_server
      context = @context
      if context
        @server.bind_tls(host: @host, port: @port, context: context)
      else
        @server.bind_tcp(host: @host, port: @port)
      end
    end

    def listen
      @server.listen
    end
    
  end
end
