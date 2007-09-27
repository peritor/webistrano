# a logger for Capistrano::Configuration that logs to the database
module Webistrano
  class Logger
    
    attr_accessor :level
    attr_accessor :deployment

    IMPORTANT = 0
    INFO      = 1
    DEBUG     = 2
    TRACE     = 3
    
    MAX_LEVEL = 3
    
    def initialize(deployment)
      raise ArgumentError, 'deployment is already completed and thus can not be logged to' if deployment.completed?
      @deployment = deployment
    end
    
    def log(level, message, line_prefix=nil)
      if level <= self.level
        indent = "%*s" % [MAX_LEVEL, "*" * (MAX_LEVEL - level)]
        
        message = hide_passwords(message)
        
        message.each do |line|
          if line_prefix
            write_msg "#{indent} [#{line_prefix}] #{line.strip}\n"
          else
            write_msg "#{indent} #{line.strip}\n"
          end
        end
      end
    end

    def important(message, line_prefix=nil)
      log(IMPORTANT, message, line_prefix)
    end

    def info(message, line_prefix=nil)
      log(INFO, message, line_prefix)
    end

    def debug(message, line_prefix=nil)
      log(DEBUG, message, line_prefix)
    end

    def trace(message, line_prefix=nil)
      log(TRACE, message, line_prefix)
    end
    
    def close
      # not needed here
    end
    
    # actual writing of a msg to the DB
    def write_msg(msg)
      @deployment.reload
      @deployment.transaction do 
        @deployment.log = (@deployment.log || '') + msg
        @deployment.save!
      end
    end
    
    # replaces deployment passwords in the message by 'XXXXX'
    def hide_passwords(message)
      scrabbled_message = message
      
      # scrabble non-prompt configs
      deployment.stage.non_prompt_configurations.each do |config|
        scrabbled_message.gsub!(config.value, "XXXXXXXX") if config.name.match(/password/)
      end
      
      # scrabble prompt configs
      deployment.prompt_config.each do |k, v|
        scrabbled_message.gsub!(v, "XXXXXXXX") if k.to_s.match(/password/)
      end
      
      scrabbled_message
    end
    
  end
end