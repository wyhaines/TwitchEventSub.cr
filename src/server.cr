require "http/server"
require "./server/*"

module TwitchEventSub
  class HttpServer
    def initialize(
      @host : String,
      @port : Int32,
      @context : OpenSSL::SSL::Context::Server
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
      @server.bind_tls(host: @host, port: @port, context: @context)
    end

  end
end
