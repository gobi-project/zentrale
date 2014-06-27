object @device

attributes :id, :name, :address, :status

child(resources: 'resources') do |res|
  extends 'resources'
end
