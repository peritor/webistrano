module Webistrano
  class Deployer
    # Mix-in the Capistrano behavior
    include Capistrano::CLI::Execute, Capistrano::CLI::Options
  
    # holds the capistrano options, see capistrano/lib/capistrano/cli/options.rb
    attr_accessor :options  
    
    # deployment (AR model) that will be deployed
    attr_accessor :deployment
    
    attr_accessor :logger
  
    def initialize(deployment)
      @options = { 
        :recipes => [], 
        :actions => [],
        :vars => {}, 
        :pre_vars => {},
        :verbose => 3 
      }
    
      @deployment = deployment
      
      if(@deployment.task && !@deployment.new_record?)
        # a read deployment
        @logger = Webistrano::Logger.new(deployment)
        @logger.level = Webistrano::Logger::TRACE
        validate
      else
        # a fake deployment in order to access tasks
        @logger = Capistrano::Logger.new
      end
    end
  
    # validates this instance
    # raises on ArgumentError if not valid
    def validate
      raise ArgumentError, 'The given deployment has no roles and thus can not be deployed!' if deployment.roles.empty?
    end
  
    # actual invokment of a given task (through @deployment)
    def invoke_task!
      options[:actions] = deployment.task
      
      case execute!
      when false
        deployment.complete_with_error!
        false
      else
        deployment.complete_successfully!
        true
      end
    end
  
    # modified version of Capistrano::CLI::Execute's execute!
    def execute!
      config = instantiate_configuration
      config.logger.level = options[:verbose]
      config.load 'deploy'

      status = catch(:abort_called_by_capistrano){
        set_webistrano_logger(config)
        
        set_up_config(config)
        
        exchange_real_revision(config) unless (config.fetch(:scm).to_s == 'git') # git cannot do a local query by default
      
        config.trigger(:load)
        execute_requested_actions(config)
        config.trigger(:exit)
      }
      
      if status == :capistrano_abort
        false
      else
        config
      end
    rescue Exception => error
      handle_error(error)     
      return false
    end
    
    # override in order to use DB logger
    def instantiate_configuration #:nodoc:
      config = Webistrano::Configuration.new
      config.logger = logger
      config
    end
    
    def set_up_config(config)
      set_pre_vars(config)
      load_recipes(config)

      set_stage_configuration(config)
      set_stage_roles(config)
      set_project_and_stage_names(config)
      load_project_template_tasks(config)
      load_stage_custom_recipes(config)
      config
    end
    
    # sets the Webistrano::Logger instance on the configuration,
    # so that it gets used by the SCM#logger
    def set_webistrano_logger(config)
      config.set :logger, logger
    end
  
    # sets the stage configuration on the Capistrano configuration
    def set_stage_configuration(config)
      deployment.stage.non_prompt_configurations.each do |effective_conf|
        config.set effective_conf.name.to_sym, Deployer.type_cast(effective_conf.value)
      end
      deployment.prompt_config.each do |k, v|
        config.set k.to_sym, Deployer.type_cast(v)
      end
    end
    
    # load the project's custom tasks
    def load_project_template_tasks(config)
      config.load(:string => deployment.stage.project.tasks)
    end
    
    # load custom project recipes
    def load_stage_custom_recipes(config)
      begin
        deployment.stage.recipes.each do |recipe|
          logger.info("loading stage recipe '#{recipe.name}' ")
          config.load(:string => recipe.body)
        end
      rescue SyntaxError, LoadError => e
        raise Capistrano::Error, "Problem loading custom recipe: #{e.message}"
      end
    end
    
    # set :real_revsion on config a version of SCM#query_revision(revision)
    # that uses Webistrano::Logger and handles errors cleaner
    def exchange_real_revision(config)
      
      # check if the scm_command exists if it is set
      if config[:scm_command] && !File.file?(config[:source].local.command)
        logger.important("Local scm command not found: #{config[:source].local.command}")
        throw :abort_called_by_capistrano, :capistrano_abort
      end
        
      config.set(:real_revision) do
        config[:source].local.query_revision(config[:revision]) do |cmd| 
          config.with_env("LC_ALL", "C") do
          
            stdout_output = ''
            stderr_output = ''
            
            status = Open4::popen4(cmd) do |pid, stdin, stdout, stderr|
              stdin.close
              stdout_output = stdout.read.strip
              stderr_output = stderr.read.strip
              #logger.trace("LOCAL SCM OUT: #{stdout_output}") unless stdout_output.blank?
              logger.important("LOCAL SCM ERROR: #{stderr_output}") unless stderr_output.blank?
            end

            if status.exitstatus != 0 # Error
              logger.important("Local scm command failed")
            
              # exit deployment in a hard way as no rollback is need (we never read the revision to deploy)
              # an alternative would be to raise Capistrano::Error, this would trigger a rollback
              throw :abort_called_by_capistrano, :capistrano_abort
            else # OK
              stdout_output
            end
          
          end
        end 
      end

    end
  
    # sets the roles on the Capistrano configuration
    def set_stage_roles(config)
      deployment.deploy_to_roles.each do |r|
        
        # create role attributes hash
        role_attr = r.role_attribute_hash
        
        if role_attr.blank?
          config.role r.name, r.hostname_and_port
        else
          config.role r.name, r.hostname_and_port, role_attr
        end
      end
    end
    
    # sets webistrano_project and webistrano_stage to corrosponding values
    def set_project_and_stage_names(config)
      config.set(:webistrano_project, deployment.stage.project.webistrano_project_name)
      config.set(:webistrano_stage, deployment.stage.webistrano_stage_name)
    end
  
    # casts a given string to the correct Ruby value
    # e.g. 'true' to true and ':sym' to :sym
    def self.type_cast(val)
      return nil if val.nil?
      
      case val.strip
      when 'true'
        true
      when 'false'
        false
      when 'nil'
        nil
      else # symbol or string
        (val.index(':') == 0) ? val.slice(1, val.size).to_sym : val
      end
    end
    
    # override in order to use DB logger 
    def handle_error(error) #:nodoc:
      case error
      when Net::SSH::AuthenticationFailed
        logger.important "authentication failed for `#{error.message}'"
      when Capistrano::Error
        logger.important(error.message)
      else 
        # we did not expect this error, so log the trace
        logger.important(error.message + "\n" + error.backtrace.join("\n"))
      end
    end
    
    # returns a list of all tasks defined for this deployer
    def list_tasks
      config = instantiate_configuration
      config.load 'deploy'
      
      set_up_config(config)
      
      config.task_list(:all)
    end
  
  end
end