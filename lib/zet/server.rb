require 'securerandom'
require 'socket'
require 'openssl'

module Zet
  attr_reader :host, :port, :listener_uuid, :server_socket
  attr_accessor :name
  class TcpListener
    def initialize(host, port, name)
      @host = host
      @port = port
      @listener_uuid = SecureRandom.uuid
      @name = name
      @server_socket = nil
    end

    def start!
      @server_socket = TCPServer.new(@host, @port)
      tl_t = Thread.start do
        Signal.trap("INT"){ exit! }
        loop do
          t = Thread.start(@server_socket.accept) do |client|
            Signal.trap("INT"){ exit! }
            handle_connection(client)
          end
          t.name = "tcp_connection_#{SecureRandom.uuid}"
          $listener_pool << t
        end
      end
      tl_t.name = "tcp_listener_port#{@port}"
      $listener_pool << tl_t
    end

    def handle_connection(client_conn)
      puts 'got connection'
      # Create a new client object and see if a client with the same IP is in the client pool
    end
  end
end
