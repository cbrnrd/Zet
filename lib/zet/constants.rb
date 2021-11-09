VERSION = "0.1.0".freeze
AUTHORS = {
    'Carter Brainerd' => '0xCB[at]protonmail[dot]com'
}
DATA_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'data'))
PUBLIC_KEY_PATH = File.join(DATA_DIR, 'zet_server_public.pem')
PRIVATE_KEY_PATH = File.join(DATA_DIR, 'zet_server_private.pem')

module Zet
module Constants
end
end
