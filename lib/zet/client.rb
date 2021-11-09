require 'securerandom'


# This class defines a Client object. One client object = one computer running the zet client
module Zet
  module Client
    attr_reader :uuid, :ip, :version, :wait_time, :failed_checkin, :kill_date
    attr_accessor :public_key, :task_queue

    
    ##########
    #
    # uuid - The UUID of this client
    # ip - the IP address of this client
    # version - the build version of the client binary
    # wait_time - the time this client waits between sending checking
    # failed_checkin - if the client has failed to check in =
    # kill_date - the date at which to stop the client
    #
    ##########
    def initialize(uuid = nil, ip = nil, version = nil, wait_time = nil, failed_checkin = false, kill_date = nil, public_key = nil)
      @uuid = uuid | SecureRandom.uuid
      @ip = ip
      @version = version
      @wait_time = wait_time
      @failed_checkin = failed_checkin
      @kill_date = kill_date
      @public_key = public_key
      @task_queue = Concurrent::Array.new # FIFO
    end

    def queue_task(task)
      # `task` is just a simple payload data string
      # will be encrypted with the clients public key (if any)
      # Will error if:
      #   - No public key exists for this client
      #   - Kill date has past
  end
end
