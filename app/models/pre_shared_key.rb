require 'codtls'

class PreSharedKey
  include ActiveModel::Validations
  extend ActiveModel::Naming
  attr_accessor :uuid, :psk, :desc

  validates_presence_of :uuid, :psk

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def save
    if valid?
      CoDTLS::SecureSocket.add_psk([uuid.tr('-', '')].pack('H*'), psk, desc)
      true
    else
      false
    end
  end

  def self.delete(uuid)
    CoDTLS::SecureSocket.del_psk(uuid.to_i)
  end

  def self.all
    CoDTLS::SecureSocket.psks.map do |psk|
      {
        id: psk[0],
        uuid: binary_to_uuid(psk[1]),
        psk: psk[2],
        desc: psk[3]
      }
    end
  end

  private

  def self.binary_to_uuid(binary)
    uuid = binary.unpack('H*').first
    uuid = uuid.scan(/../)
    uuid[0, 4].join('') + '-' +
      uuid[4, 2].join('') + '-' +
      uuid[6, 2].join('') + '-' +
      uuid[8, 2].join('') + '-' +
      uuid[10, 6].join('')
  end
end
