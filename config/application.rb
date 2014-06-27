$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'boot'
require 'logger'
require 'socket'

root_dir = File.expand_path('../../', __FILE__)
db_dir = File.expand_path("#{root_dir}/db", __FILE__)
config_dir = File.dirname(__FILE__)

$LOAD_PATH.unshift root_dir
##
# Rails stub for compatibility
class Rails
  def self.root
    File.expand_path('../../', __FILE__)
  end
  def self.env
    ENV['RACK_ENV']
  end
end

##
# Main application module
module Application
  include ActiveSupport::Configurable
end

module App
  module_function

  def log
    if @logger.nil?
      @logger = Logger.new("#{File.expand_path('../../', __FILE__)}/log/#{ENV['RACK_ENV']}.log", 10, 5_242_880)
      @logger.level = Logger::DEBUG  # DEBUG, ERROR, FATAL, INFO, UNKNOWN, WARN
      @logger.formatter = proc do |severity, datetime, progname, msg|
        "#{severity} :: #{datetime.strftime('%Y-%m-%d :: %H:%M:%S')} :: #{progname} :: #{msg}\n"
      end
    end
    @logger
  end

  def name
    hostname = Socket.gethostname
    "Gobi Server on #{hostname}"
  end
end

##
# SeedLoader for active_record
class SeedLoader
  def self.load_seed
    require File.expand_path('../../db/seeds', __FILE__)
  end
end

Application.configure do |config|
  config.root     = root_dir
  config.env      = ENV['RACK_ENV'].to_s
end

ActiveRecord::Base.configurations = YAML.load(File.read(File.join(config_dir, 'database.yml')))
ActiveRecord::Base.establish_connection ActiveRecord::Base.configurations[ENV['RACK_ENV'].to_s].symbolize_keys
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Tasks::DatabaseTasks.database_configuration = ActiveRecord::Base.configurations
ActiveRecord::Tasks::DatabaseTasks.db_dir = db_dir
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = File.join(db_dir, 'migrate')
ActiveRecord::Tasks::DatabaseTasks.root = root_dir
ActiveRecord::Tasks::DatabaseTasks.env = ENV['RACK_ENV'].to_s
ActiveRecord::Tasks::DatabaseTasks.seed_loader = SeedLoader
ActiveRecord::Base.logger = Logger.new("#{root_dir}/log/activerecord.log")

ApplicationServer = Rack::Builder.new do
# TODO: generate ssl cert and enable later
#  if ['production'].include? Application.config.env
#    Rack::SslEnforcer
#  end
  map '/' do
    run API::Root
  end
end

Dir["#{File.dirname(__FILE__)}/../app/api/api/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/../app/**/*.rb"].each { |f| require f }
Dir["#{File.dirname(__FILE__)}/initializers/**/*.rb"].each { |f| require f }

I18n.enforce_available_locales = false
