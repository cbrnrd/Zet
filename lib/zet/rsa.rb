module Zet
  module RSA
    
    # This class keeps an in-memory hash of client -> RSA public key associations
    class InMemoryDB
      
      attr_reader :pairs

      def initialize
        @pairs = Concurrent::Hash.new
      end

      def add_pair(client_id, public_key)
        @pairs[client_id] = public_key
      end

      def get_key(client_id)
        return @pairs[client_id]
      end

      def delete_pair(client_id)
        @pairs.delete(client_id)
      end

      def clear_db
        @pairs = Concurrent::Hash.new
      end

    end
  end
end
