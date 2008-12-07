module Webistrano
  module Template
    module ThinRails
      
      CONFIG = Webistrano::Template::Rails::CONFIG.dup.merge({
        :thin_config => 'PATH to thin_cluster.yml, you need to create it yourself' 
      }).freeze
      
      DESC = <<-'EOS'
        Template for use of Rails projects that use Thin.
        Defines the 'thin_config' configuration parameter that should point
        to a working Thin configuration, e.g.:
          
  <pre>
  --- 
  chdir: /opt/my_app/current
  port: "8000"
  log: log/thin.log
  max_conns: 1024
  timeout: 30
  environment: production
  max_persistent_conns: 512
  daemonize: true
  require: []
  address: 0.0.0.0
  pid_file: log/thin.pid
  servers: 2
  </pre>
        Overrides the deploy.restart, deploy.start, and deploy.stop tasks to use
        Thin instead.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      
        namespace :webistrano do
          namespace :thin do
            [ :stop, :start, :restart ].each do |t|
              desc "#{t.to_s.capitalize} thin"
              task t, :roles => :app, :except => { :no_release => true } do
                as = fetch(:runner, "app")
                invoke_command "thin -C #{thin_config} #{t.to_s}", :via => run_method, :as => as
              end
            end
          end
        end
        
        namespace :deploy do
          task :restart, :roles => :app, :except => { :no_release => true } do
            webistrano.thin.stop
            sleep(5)
            webistrano.thin.start
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            webistrano.thin.start
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            webistrano.thin.stop
          end
        end
      EOS
      
    end
  end
end