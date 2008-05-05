module Webistrano
  module Template
    module ModRails
      
      CONFIG = Webistrano::Template::Rails::CONFIG.dup.merge({
        :mod_rails_restart_file => 'Absolut path to restart.txt',
        :apache_init_script => 'Absolut path to Apache2.2 init script, e.g. /etc/init.d/apache22'
      }).freeze
      
      DESC = <<-'EOS'
        Template for use of mod_rails / Passenger projects that use Apache2.2 with mod_rails.
        Defines the 'mod_rails_restart_file' configuration parameter that should point
        to /your/app/tmp/restart.txt. Further if you want Webistrano to control Apache2.2,
        you need to set 'apache_init_script'.

        Overrides the deploy.restart, deploy.start, and deploy.stop tasks to use
        mod_rails commands instead.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      
        namespace :webistrano do
          namespace :mod_rails do
            desc "start mod_rails & Apache"
            task :start, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              invoke_command "#{apache_init_script} start", :via => run_method, :as => as
            end
            
            desc "stop mod_rails & Apache"
            task :stop, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              invoke_command "#{apache_init_script} stop", :via => run_method, :as => as
            end
            
            desc "restart mod_rails"
            task :restart, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              restart_file = fetch(:mod_rails_restart_file, "#{deploy_to}/current/tmp/restart.txt")
              invoke_command "touch #{restart_file}", :via => run_method, :as => as
            end
          end
        end
        
        namespace :deploy do
          task :restart, :roles => :app, :except => { :no_release => true } do
            webistrano.mod_rails.restart
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            webistrano.mod_rails.start
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            webistrano.mod_rails.stop
          end
        end
      EOS
      
    end
  end
end