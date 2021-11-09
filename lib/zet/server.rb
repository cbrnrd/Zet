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
      puts 'got connection'

      # See if the client has actually sent any data that identifies itself. 

      # Create a new client object and see if a client with the same IP is in the client pool
      client = Zet::Client.new(ip: client_conn.peeraddr[3])
      p client
      if Zet::ClientPool.get_client_by_ip(client.ip).nil?
        puts "Client not in client pool"
        Zet::ClientPool.add_client(client)
      end
      
      # Message types from client:
      #   - KEY EXCHANGE (1)
      #   - DATA (2)
      #   - BEACON (3)
      #
      #  On KEY EXCHANGE messages, the payload format is 
      #     FROM CLIENT: `1//{CLIENT_PUBLIC_KEY_TEXT}`
      #     TO CLIENT: `1//{SERVER_PUBLIC_KEY_TEXT}`
      #
      #  On DATA messages, the payload format is
      #     FROM CLIENT: `2//{DATA}`
      #
      #  On BEACON messages, the payload format is ONE OF:
      #     `3//CHECKIN` or `3//REQTASK`
      #         For `CHECKIN` beacons, don't send back anything
      #         For `REQTASK` beacons, send back a task if there is one in the client queue, otherwise send `3//NONE`
    end
  end
end
