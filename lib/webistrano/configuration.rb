# Webistranos implementation of Capistrano::Configuration
# uses a Webistrano::Logger as the logger in order to log to the DB
module Webistrano
  class Configuration < Capistrano::Configuration
      
    attr_accessor :logger
      
    # default callback to handle all output that
    # the other callbacks not explicitly handle.
    def self.default_io_proc
      Proc.new do |ch, stream, out|
        level = stream == :err ? :important : :info
        ch[:options][:logger].send(level, out, "#{stream} :: #{ch[:server]}")
      end
    end
  end
end