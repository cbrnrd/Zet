module Zet
  class Messages
    KEY_EXCHANGE = 1
    DATA = 2
    BEACON = 3
    DATA_FRAGMENT = 4

    # Creates a server -> client key exchange message
    def self.create_stc_kex_message(public_key)
      # Simple TLV payload, so:
      # TYPE = KEY_EXCHANGE = 1
      # LENGTH = len(public_key)
      # VALUE = public_key
      pld = ''
      pld << KEY_EXCHANGE
      pld << public_key.length
      pld << public_key
      return Zet::Messages.build_message(pld)
    end

    def create_stc_data_message(data)
      pld = ''
      pld << DATA
      pld << data.length
      pld << data
      return Zet::Messages.build_message(pld)
    end

    # Don't really need to create beacon message, since server never sends beacons to clients

    # This method builds a valid message with the given payload.
    # Assumes the payload has already been encrypted
    def self.build_message(payload)

      # Packed in unsigned int, big endian 

      crc_len = rand(199)
      
      msg = ''
      # Initial 8 byte random data
      msg << Random.urandom(8)

      msg << [crc_len].pack("C")

      # Random data of size 0-199
      msg << Random.urandom(crc_len)

      #msg << [msg.length].pack("C") # 8-bit unsigned
      msg << [payload.length].pack("S>") # 16-bit big endian unsigned int

      # Pad
      msg << Random.urandom(8)

      msg << payload

      # 2nd pad
      msg << Random.urandom(8)
      msg << Random.urandom(rand(149))
      return msg
    end

    def self.unpack_message(msg)
      anchor_idx = msg[8].unpack("C")[0] + 9
      pld_len = msg[anchor_idx..anchor_idx+1].unpack("S>")[0]

      return msg[anchor_idx+10...anchor_idx+10+pld_len]
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
    def self.handle_valid_message(msg_type, uuid, msg, client, client_conn)
      # Check if client is in client pool (by uuid) already, add it if not
      if Zet::ClientPool.get_client_by_uuid(uuid).nil?
        Zet::ClientPool.add_client(client)
      end

      case msg_type
      when KEY_EXCHANGE
        
      when DATA
        
      when BEACON

      when DATA_FRAGMENT

      else
        puts "(#{client.ip}) - Invalid message type: #{msg_type}"
      end
    end



    def self.msg_breakdown(msg)
      break_idx = 0

      p "First 8 bytes: #{msg[0..7]}"
      p "MSG: #{msg}"
      anchor_idx = msg[8].unpack("C")[0] + 9 # Index of the start of the size(pld) bytes
      puts "First data chunk size: #{anchor_idx - 9}"
      p "First random data chunk: #{msg[9...anchor_idx]}"
      pld_len = msg[anchor_idx..anchor_idx+1].unpack("S>")[0]
      p "Payload length: #{pld_len}"
      p "Payload: #{msg[anchor_idx+10...anchor_idx+10+pld_len]}"
    end



    def self.test_distribution(payload_size=256)

      lengths = []
      pld = Random.urandom(payload_size)
      printed_msg = false
      100000.times do
        msg = Zet::Messages.build_message(pld)
        lengths << msg.length
        unless printed_msg
          puts "Sample payload:"
          p pld
          puts "Sample message:"
          p msg
          printed_msg = true
        end
      end

      max = lengths.max
      min = lengths.min
      avg = lengths.sum.to_f / lengths.size

      puts "MAX: #{max}"
      puts "MIN: #{min}"
      puts "AVG: #{avg}"
      hist = Hash[*lengths.group_by{ |v| v }.flat_map{ |k, v| [k, v.size] }].sort.to_h
      PP.pp("Histogram: #{hist}", $>, 30)
      return hist
    end
  end
end
