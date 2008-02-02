module Webistrano
  module Template
    module MongrelRails
      
      CONFIG = Webistrano::Template::Rails::CONFIG.dup.merge({
        :mongrel_config => 'PATH to mongrel_cluster.yml, you need to create it yourself' 
      }).freeze
      
      DESC = <<-'EOS'
        Template for use of Rails projects that use Mongrel + MongrelCluster.
        Defines the 'mongrel_config' configuration parameter that should point
        to a working Mongrel Cluster configuration, e.g.:
          
  <pre>
  --- 
  cwd: /opt/my_app/current
  port: "8000"
  environment: production
  address: 0.0.0.0
  pid_file: log/mongrel.pid
  servers: 2
  </pre>
        Overrides the deploy.restart, deploy.start, and deploy.stop tasks to use
        Mongrel Cluster instead.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      
        namespace :webistrano do
          namespace :mongrel do
            [ :stop, :start, :restart ].each do |t|
              desc "#{t.to_s.capitalize} mongrel"
              task t, :roles => :app, :except => { :no_release => true } do
                as = fetch(:runner, "app")
                invoke_command "mongrel_rails cluster::#{t.to_s} -C #{mongrel_config} --clean", :via => run_method, :as => as
              end
            end
          end
        end
        
        namespace :deploy do
          task :restart, :roles => :app, :except => { :no_release => true } do
            webistrano.mongrel.stop
            sleep(5)
            webistrano.mongrel.start
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            webistrano.mongrel.start
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            webistrano.mongrel.stop
          end
        end
      EOS
      
    end
  end
end