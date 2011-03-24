module Webistrano
  module Template
    module Unicorn
      
      CONFIG = Webistrano::Template::Rails::CONFIG.dup.merge({
        :unicorn_workers => '8',
        :unicorn_workers_timeout => '30',
        :unicorn_user => 'user',
        :unicorn_group => 'group',
        :unicorn_bin => 'bundle exec unicorn',
        :unicorn_socket => 'Absolute path to Unicorn socket',
        :unicorn_pid => 'Absolute path to the pid of the Unicorn process',
        :unicorn_create_config => "no"
      }).freeze
      
      DESC = <<-'EOS'
        Template for use of Unicorn projects irrespective of web server on top.

        Overrides the deploy.restart, deploy.start, and deploy.stop tasks to use
        unicorn signals instead.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      
        set(:unicorn_remote_config) { "#{shared_path}/config/unicorn.rb" } unless exists?(:unicorn_remote_config)

        def unicorn_start_cmd
          "cd #{current_path} && #{unicorn_bin} -c #{unicorn_remote_config} -E #{rails_env} -D"
        end

        def unicorn_stop_cmd
          "kill -QUIT `cat #{unicorn_pid}`"
        end

        def unicorn_restart_cmd
          "kill -USR2 `cat #{unicorn_pid}"
        end
      
        namespace :webistrano do
          namespace :unicorn do
            desc "Start Unicorn directly"
            task :start, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              invoke_command "#{unicorn_start_cmd} start", :via => run_method, :as => as
            end
            
            desc "Stop Unicorn directly"
            task :stop, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              invoke_command "#{unicorn_stop_cmd} stop", :via => run_method, :as => as
            end
            
            desc "Restart Unicorn app directly"
            task :restart, :roles => :app, :except => { :no_release => true } do
              as = fetch(:runner, "app")
              invoke_command "#{unicorn_restart_cmd}", :via => run_method, :as => as
            end

            desc "Generates Unicorn config from variables"
            task :setup, :roles => :app, :except { :no_release => true } do
              as = fetch(:runner, "app")
              commands = []
              commands << "mkdir -p #{sockets_path}"
              commands << "chown #{user}:#{group} #{sockets_path} -R"
              commands << "chmod +rw #{sockets_path}"

              invoke_command commands.join(" && "), :via => run_method, :as => as
              unicorn_config = <<-EOF
              rails_root = "#{deploy_to}/current"
              rails_env  = "#{environment}"
              pid_file   = "#{unicorn_pid}"
              socket_file= "#{unicorn_socket}"
              log_file   = "#{rails_root}/log/unicorn.log"
              username   = "#{unicorn_user}"
              group      = "#{unicorn_group}"
              old_pid    = pid_file + '.oldbin'


              timeout #{unicorn_workers_timeout}

              worker_processes #{unicorn_workers}

              # Listen on a Unix data socket
              listen socket_file, :backlog => 1024
              pid pid_file

              stderr_path log_file
              stdout_path log_file

              preload_app true
              ##
              # REE

              GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

              before_fork do |server, worker|
                # the following is highly recomended for Rails + "preload_app true"
                # as there's no need for the master process to hold a connection
                defined?(ActiveRecord::Base) and
                  ActiveRecord::Base.connection.disconnect!


                ##
                # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
                # immediately start loading up a new version of itself (loaded with a new
                # version of our app). When this new Unicorn is completely loaded
                # it will begin spawning workers. The first worker spawned will check to
                # see if an .oldbin pidfile exists. If so, this means we've just booted up
                # a new Unicorn and need to tell the old one that it can now die. To do so
                # we send it a QUIT.
                #
                # Using this method we get 0 downtime deploys.

                if File.exists?(old_pid) && server.pid != old_pid
                  begin
                    Process.kill("QUIT", File.read(old_pid).to_i)
                  rescue Errno::ENOENT, Errno::ESRCH
                    # someone else did our job for us
                  end
                end
              end


              after_fork do |server, worker|
                  defined?(ActiveRecord::Base) and
                  ActiveRecord::Base.establish_connection


                worker.user(username, group) if Process.euid == 0 && rails_env == 'production'
              end
              EOF
              put unicorn_config, unicorn_remote_path
            end
          end
        end
        
        namespace :deploy do
          task :restart, :roles => :app, :except => { :no_release => true } do
            webistrano.unicorn.restart
          end
          
          task :start, :roles => :app, :except => { :no_release => true } do
            webistrano.unicorn.start
          end
          
          task :stop, :roles => :app, :except => { :no_release => true } do
            webistrano.unicorn.stop
          end
        end

        after 'deploy:setup' do
          create_config = unicorn_create_config.to_lower.sub(" ", "")
          unicorn.setup if create_config === "y" or create_config === "yes" or create_config === "true" or create_config === "t"
        end
      EOS
      
    end
  end
end
