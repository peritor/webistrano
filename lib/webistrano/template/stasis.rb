module Webistrano
  module Template
    module Stasis
      
      CONFIG = Webistrano::Template::Base::CONFIG.dup.merge({
      }).freeze
      
      DESC = <<-'EOS'
	Template for use with non-rails stasis projects that just update 'pure' files.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
         namespace :deploy do
           task :update_code, :except => { :no_release => true } do
             strategy.deploy!
           end

           task :symlink, :roles => :app, :except => { :no_release => true } do
             logger.trace "doing nothing"
           end

           task :restart, :roles => :app, :except => { :no_release => true } do
             logger.trace "doing nothing"
           end
         end
      EOS
    end
  end
end
