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
      # Start listening socket
      @server_socket = TCPServer.new(@host, @port)

      # Create a new thread to create threads on each client connection and add them to the thread pool
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

      client_ip = client_conn.peeraddr[3]

      # Create a new client object and see if a client with the same IP is in the client pool
      client = Zet::Client.new(uuid: '', ip: client_ip)
      # Size:
      # 8 + 1 + (0-199) + 2 + 8 + (0-2048) + 8 + (0-149)
      # Min size: 28 bytes
      # Max size: 2423 bytes
      raw_msg = client_conn.recv(2500) # Over read a little bit
      begin
        msg = Zet::Messages.unpack_message(raw_msg)
        p "#{msg}"
        if (msg.split('/').length < 3)
          puts "[ERROR] - Invalid message from #{client.ip}"
          return
        end
        msg_type, uuid, msg  = msg.split('/', 3)
        client.uuid = uuid
        Zet::Messages.handle_valid_message(msg_type, uuid, msg, client, client_conn)
      rescue NoMethodError
        # invalid message
        puts "[ERROR] - Invalid message from #{client.ip}"
        return
      end
    end
  end
end
