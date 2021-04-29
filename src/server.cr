require "http/server"
require "./server/*"

module TwitchEventSub
  # To Handle EventSub notifications and interactions, an HTTP Server
  # must be running to receive the callbacks. This class encapsulates
  # a very simple HTTP server that binds a TwitchHandler to the server
  # stack for handling those requests.

  @@secrets = Hash(String, String).new

  class HttpServer
    def initialize(
      secrets,
      @host : String = "127.0.0.1",
      @port : Int32 = 8080,
      @context : OpenSSL::SSL::Context::Server? = nil
    )
      @server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
        TwitchEventSub::HttpServer::TwitchHandler.new(secrets),
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
