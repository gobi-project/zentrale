DNSSD.register(App.name, '_gobi._tcp', nil, 9001) do |r|
  App.log.debug "successfully registered: #{r.inspect}"
end
