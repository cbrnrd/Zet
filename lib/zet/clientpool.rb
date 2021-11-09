

module Zet
  class ClientPool

    def self.add_client(client)
      $client_pool << client
    end

    def self.delete_client(client)
      $client_pool.delete(client) if $client_pool.include?(client)
      # TODO: log
    end

    def self.get_client_by_uuid(uuid)
      $client_pool.each do |c|
        return c if c.uuid == uuid
      end
      return nil
    end

    def self.get_client_by_ip(ip)
      $client_pool.each do |c|
        return c if c.ip == ip
      end
      return nil
    end

    def self.delete_client_at(idx)
      $client_pool.delete_at(idx)
    end
  end
end
