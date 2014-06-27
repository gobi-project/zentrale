require 'codtls'
require 'coap'

if ENV['RACK_ENV'] == 'production'
  App.log.debug 'Start HelloRequest Listener'

  # Listener for CoDTLS-HelloRequest
  class HelloListener
    def self.info(numeric_address)
      App.log.debug "Hello Request from #{numeric_address}"
      return if numeric_address.nil?
      device = Device.where(address: numeric_address).first_or_create
      unless device.status == :handshake
        device.status = :rehandshake
        device.save
      end
    end
  end

  CoDTLS::SecureSocket.add_new_node_listener(HelloListener)
end
