# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_webistrano_session',
    :secret      => '4a850072e0e38kvi8#e3abcbf3e0702f0c0cfab35c7e29cbee5e6f267cd8b652ffa24jkasjdh78jk3-0a9:~&@90fb7759e073f0f6ba4b0607bc10324c'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below

WEBISTRANO_VERSION = '1.2'

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:log => '%Y-%m-%d %H:%M')
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:date_with_day => '%Y-%m-%d')

require 'open4'
require 'capistrano/cli'
require 'syntax/convertors/html'

# load Webistrano configuration
require "#{RAILS_ROOT}/config/webistrano_config"

ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method] 
ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings] 

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]

ExceptionNotifier.exception_recipients = WebistranoConfig[:exception_recipients] 
ExceptionNotifier.sender_address = WebistranoConfig[:exception_sender_address] 


# delete cached stylesheet on boot in order to delete stale versions
File.delete("#{RAILS_ROOT}/public/stylesheets/application.css") if File.exists?("#{RAILS_ROOT}/public/stylesheets/application.css")

# set default time_zone to UTC
ENV['TZ'] = 'UTC'
TzTime.zone = TimeZone['Edinburgh']