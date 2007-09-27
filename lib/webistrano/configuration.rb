# Webistranos implementation of Capistrano::Configuration
# uses a Webistrano::Logger as the logger in order to log to the DB
module Webistrano
  class Configuration < Capistrano::Configuration
    
    attr_accessor :logger
      
  end
end