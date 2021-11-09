module Zet
  class ListenerPool
    def self.lint_pool
      p $listener_pool
      $listener_pool.each do |t|
        unless t.status
          $listener_pool.delete(t)
        end
      end
    end
  
    def self.start_linter!(interval)
      puts "Starting linter"
      Thread.start do
        while
          lint_pool
          sleep(interval)
        end
      end
    end
  
  end
  end
  