require 'coap'
require 'tits'

class Resource < TITS::Base
  belongs_to :device
  has_and_belongs_to_many :groups
  after_create :create_torf_resource
  after_commit :start_observer
  before_destroy :destroy_data

  def value
    measurement = current_measurement
    measurement.value unless measurement.nil?
  end

  def update_resource(params)
    if interface_type == 'core.a' && params.include?(:value)
      add_measurement(params[:value], Time.now)

      App.log.debug "Update Actuator #{id}, set value to #{params[:value]}"
      client = CoAP::Client.new
      client.use_dtls
      value = params[:value].to_s
      client.post(device.address, 5684, path, value)
    end
    params.except!(:value)
    update(params)
  end

  def stop_observer
    Observer.instance.del id
  end

  private

  def create_torf_resource
    TorfResource.create(id: id, name: name, value: 0, default_value: 0)
  end

  def destroy_data
    delete_series
    TorfResource.find(id).destroy
    Observer.instance.del id
  end

  def start_observer
    unless resource_type.nil? || device.nil?
      Observer.instance.add id, device.address, path if interface_type == 'core.s'
    end
  end
end
