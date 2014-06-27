object @group

attributes :id, :name

child(resources: 'resources') do |res|
  extends 'resources'
end

child(rules: 'rules') do |rule|
  extends 'rules'
end
