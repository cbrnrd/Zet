

module Zet
    class ClientPool
        attr_accessor :pool
        def initialize()
            @pool = Concurrent::Array.new
        end

        def add_client(client)
            @pool << client
        end

        def delete_client(client)
            pool.delete(client) if @pool.include?(client)
            # TODO: log
        end

        def delete_client_at(idx)
            @pool.delete_at(idx)
        end
    end
end
