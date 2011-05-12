# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

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
    :key    => '_webistrano_session',
    :secret => WebistranoConfig[:session_secret]
  }

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  
  config.gem 'net-ssh', :version => '2.0.15', :lib => 'net/ssh'
  config.gem 'net-scp', :version => '1.0.2', :lib => 'net/scp'
  config.gem 'net-sftp', :version => '2.0.2', :lib => 'net/sftp'
  config.gem 'net-ssh-gateway', :version => '1.0.1', :lib => 'net/ssh/gateway'
  config.gem 'capistrano', :version => '2.5.9'
  config.gem 'highline', :version => '1.5.1'
  config.gem 'open4', :version => '0.9.3'
  config.gem 'syntax', :version => '1.0.0'
end

require 'open4'
require 'capistrano/cli'
require 'syntax/convertors/html'

# delete cached stylesheet on boot in order to delete stale versions
File.delete("#{RAILS_ROOT}/public/stylesheets/application.css") if File.exists?("#{RAILS_ROOT}/public/stylesheets/application.css")

# set default time_zone to UTC
ENV['TZ'] = 'UTC'
Time.zone = 'UTC'