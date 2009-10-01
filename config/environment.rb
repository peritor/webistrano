# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# load Webistrano configuration
require "#{RAILS_ROOT}/config/webistrano_config"

Rails::Initializer.run do |config|

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_webistrano_session',
    :secret      => WebistranoConfig[:session_secret]
  }

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  
  config.gem 'net-ssh', :version => '2.0.15', :lib => 'net/ssh'
  config.gem 'net-scp', :version => '1.0.2', :lib => 'net/scp'
  config.gem 'net-sftp', :version => '2.0.2', :lib => 'net/sftp'
  config.gem 'net-ssh-gateway', :version => '1.0.1', :lib => 'net/ssh/gateway'
  config.gem 'capistrano', :version => '2.5.9'
  config.gem 'mocha', :version => '0.4.0'
  config.gem 'highline', :version => '1.5.1'
  config.gem 'open4', :version => '0.9.3'
  config.gem 'syntax', :version => '1.0.0'
end


# Include your application configuration below

if WebistranoConfig[:authentication_method] == :cas
  cas_options = YAML::load_file(RAILS_ROOT+'/config/cas.yml')
  CASClient::Frameworks::Rails::Filter.configure(cas_options[RAILS_ENV])
end

WEBISTRANO_VERSION = '1.5'

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:log => '%Y-%m-%d %H:%M')
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:date_with_day => '%Y-%m-%d')

require 'open4'
require 'capistrano/cli'
require 'syntax/convertors/html'

ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method] 
ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings] 

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]

ExceptionNotifier.exception_recipients = WebistranoConfig[:exception_recipients] 
ExceptionNotifier.sender_address = WebistranoConfig[:exception_sender_address] 


# delete cached stylesheet on boot in order to delete stale versions
File.delete("#{RAILS_ROOT}/public/stylesheets/application.css") if File.exists?("#{RAILS_ROOT}/public/stylesheets/application.css")

# set default time_zone to UTC
ENV['TZ'] = 'UTC'
Time.zone = 'UTC'