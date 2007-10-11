module Webistrano
  module Template
    module PureFile
      
      CONFIG = Webistrano::Template::Base::CONFIG.dup.merge({
      }).freeze
      
      DESC = <<-'EOS'
        Template for use with non-rails projects that just update 'pure' files.
        The basic (re)start/stop tasks of Capistrano are overrided with NOP tasks.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      
         namespace :deploy do
           task :restart, :roles => :app, :except => { :no_release => true } do
             # do nothing
           end

           task :start, :roles => :app, :except => { :no_release => true } do
             # do nothing
           end

           task :stop, :roles => :app, :except => { :no_release => true } do
             # do nothing
           end
         end
      EOS
    
    end
  end
end