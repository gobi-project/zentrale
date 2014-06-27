require 'coap'

coaplog = Logger.new("#{File.expand_path(Rails.root, __FILE__)}/log/coap.log", 10, 5_242_880)
coaplog.formatter = proc do |severity, datetime, progname, msg|
  "#{severity} :: #{datetime.strftime('%Y-%m-%d :: %H:%M:%S')} :: #{progname} :: #{msg}\n"
end
coaplog.level = Logger::WARN  # DEBUG, ERROR, FATAL, INFO, UNKNOWN, WARN

CoAP.logger = coaplog
