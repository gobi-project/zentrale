class Device < ActiveRecord::Base
  STATUS = { initialize: 0, active: 1, inactive: 2, rescan: 3, handshake: 4, rehandshake: 5 }
  before_save :check_status
  after_commit :scan_device
  before_destroy :destroy_resources

  has_many :resources
  validates_inclusion_of :status, in: STATUS, allow_nil: true

  def status
    STATUS.key(read_attribute(:status))
  end

  def status=(value)
    write_attribute(:status, STATUS[value.to_sym])
  end

  private

  def check_status
    return if changed_attributes['status'].nil?
    if status == :inactive
      resources.each do |r|
        r.stop_observer
      end
    end
  end

  def scan_device
    DeviceInitializer.run
  end

  def destroy_resources
    resources.destroy_all unless resources.nil?
  end
end
