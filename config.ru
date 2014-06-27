#\ -p 3001
require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Config do |env|
  env['api.tilt.root'] = "#{File.dirname(__FILE__)}/app/api/templates"
end

use ActiveRecord::ConnectionAdapters::ConnectionManagement # https://github.com/intridea/grape/issues/517

require 'rack/cors'
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :delete, :patch, :options]
  end
end


unless ENV['RACK_ENV'] == 'test' || ENV['NODAEMON']
  Observer.run
  DeviceInitializer.run
end

run ApplicationServer
