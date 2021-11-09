require 'socket'
require 'securerandom'
require 'packetfu'
require 'optparse'
require 'paint'
require 'concurrent-ruby'
require 'xorcist'
require 'aes'
require 'pp'

$listener_pool = Concurrent::Array.new
$client_pool = Concurrent::Array.new


require_relative './zet/base64'
require_relative './zet/constants'
require_relative './zet/server'
require_relative './zet/listenerpool'
require_relative './zet/clientpool'
require_relative './zet/messages'
require_relative './zet/rsa'
require_relative './zet/client'

