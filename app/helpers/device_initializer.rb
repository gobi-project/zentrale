require 'thread'
require 'codtls'
##
# DeviceInitializer
# Requests name and /well-known/core from devices
class DeviceInitializer
  include Singleton
  attr_writer :running

  def initialize
    @mtx = Mutex.new
  end

  def self.run
    return if ENV['NODAEMON']
    App.log.debug 'DeviceInitializer run'
    instance.start
  end

  def start
    @running = true
    Thread.new do
      return unless @mtx.try_lock
      begin
        loop do
          @running = false
          devices = []
          ActiveRecord::Base.connection_pool.with_connection do
            devices = Device.where(status: [Device::STATUS[:initialize],
                                            Device::STATUS[:rescan],
                                            Device::STATUS[:handshake],
                                            Device::STATUS[:rehandshake]
                                           ])
            devices = devices.to_a.map(&:serializable_hash)
          end
          App.log.debug "Found #{devices.size} devices for init"
          devices.each do |device|
            begin
              if device['status'] == :initialize
                init_device device
              elsif device['status'] == :rescan
                request_resources(device, '/.well-known/core')
              elsif device['status'] == :handshake
                perform_handshake(device, false)
              elsif device['status'] == :rehandshake
                perform_handshake(device, true)
              end
            rescue => e
              App.log.debug "Device init got exception #{e.class}"
              App.log.debug e.backtrace
              @running = true
            end
          end
          break unless @running
          sleep(5) # TODO: delay for devices with errors
        end
      ensure
        @mtx.unlock
      end
    end
  end

  private

  def init_device(device)
    return unless device['status'] == :initialize
    App.log.debug "Initialize node #{device['address']}"
    client = CoAP::Client.new.use_dtls
    answer = client.get(device['address'], 5684, '/d/name')
    ActiveRecord::Base.connection_pool.with_connection do
      d = Device.find_by_id(device['id'])
      d.name = answer.payload.force_encoding('UTF-8')
      device['name'] = d.name
      d.status = :rescan
      d.save
    end
    request_resources device, '/.well-known/core'
  end

  def request_resources(device, path, nested = false)
    return unless device['status'] == :rescan
    App.log.debug "Request WellKnown from node #{device['address']}"
    client = CoAP::Client.new.use_dtls
    answer = client.get(device['address'], 5684, path)
    answer.payload.force_encoding('UTF-8')

    resources = CoRELinkFormatParser.parse_core_link_format(answer.payload)
    App.log.debug "Node #{device['address']} has #{resources.size} resources"

    link_list = []
    ActiveRecord::Base.connection_pool.with_connection do
      resources.each do |res|
        next unless res.resource_type.start_with?('gobi')
        r = Resource.where(
                    name: "#{device['name']}.#{res.resource_type.nil? ? 'unknown_type' : res.resource_type}",
                    interface_type: res.interface,
                    resource_type: res.resource_type,
                    path: res.link,
                    device_id: device['id']
                ).first_or_create
        link_list << r.path if r.interface_type == 'core.ll'
      end
    end
    link_list.each do |link_path|
      request_resources device, link_path, true
    end

    unless nested
      ActiveRecord::Base.connection_pool.with_connection do
        d = Device.find_by_id(device['id'])
        d.status = :active
        d.save
      end
    end
  end

  def perform_handshake(device, re)
    code, uuid = CoDTLS::Handshake.handshake(device['address'])
    App.log.debug "Code #{code} for address #{device['address']}"
    case code
    when 0
      ActiveRecord::Base.connection_pool.with_connection do
        d = Device.find_by_id(device['id'])
        d.status = re ? :active : :initialize
        d.save
      end
    when 6
      Notification.where(text: "Neues Gerät mit UUID: #{uuid} gefunden").first_or_create
      return
    else
      DeviceInitializer.run
      App.log.debug "Code #{code} not supported"
    end
  end
end
