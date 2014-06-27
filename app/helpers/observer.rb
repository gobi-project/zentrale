require 'singleton'
require 'coap'

##
# Observer
# starts observer thread for all resourdces with resource_type gobi.s
class Observer
  include Singleton

  def initialize
    @observers = {}
  end

  def self.run
    resources = []
    ActiveRecord::Base.connection_pool.with_connection do
      resources = Resource.where('resource_type like ?', 'gobi.s%')
      resources.each do |res|
        instance.add res.id, res.device.address, res.path
      end
    end
  end

  def add(res_id, device_address, res_path)
    return if @observers.nil?
    return if ENV['NODAEMON']
    App.log.debug "Try adding observer for #{res_id} from #{device_address}"
    if @observers[res_id].nil? ||  @observers[res_id].status.nil?
      @observers[res_id] = Thread.new do
        client = CoAP::Client.new
        client.use_dtls

        delay = 2
        loop do
          last = Time.now
          begin
            client.observe(device_address, 5684, res_path, method(:create_measurement))
          rescue => e
            App.log.debug "Observer for #{device_address}#{res_path} got exception #{e.class}"
          end
          delay = 2 if (Time.now - last).to_i > delay
          delay = delay >= 120 ? 120 : delay + 2 # delay max 120sec
          App.log.debug "Observer for #{device_address}#{res_path}. Retry in #{delay} seconds"
          sleep(delay)
        end
      end
    else
      App.log.debug 'Observer already exists'
    end
  end

  def del(res_id)
    return if @observers.nil?
    unless @observers[res_id].nil?
      Thread.kill(@observers[res_id])
      @observers[res_id] = nil
    end
  end

  private

  def create_measurement(value, socket)
    App.log.debug "Payload #{value.payload}"
    begin
      sensor_readings = SenMLParser.parse_json(value.payload)
    rescue SenMLParseException => e
      App.log.debug "Parser error: #{e}"
      return
    end

    App.log.debug "Value: #{sensor_readings[0].value} Time: #{sensor_readings[0].time}"
    resource = nil
    ActiveRecord::Base.connection_pool.with_connection do
      resource = Resource.includes(:device).where('path = ? and devices.address = ?', sensor_readings[0].name, socket[1][2]).references(:device).first
      unless resource.nil?
        if resource.unit.nil?
          resource.unit = sensor_readings[0].unit
          resource.save
        end
      end
    end
    App.log.debug "Found Resource #{resource.id}, try to add measurement" unless resource.nil?
    resource.add_measurement(sensor_readings[0].value, sensor_readings[0].time) unless resource.nil?
  end
end
