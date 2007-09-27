module Webistrano
  module Template
    module Base
      CONFIG = {
        :application => 'your_app_name',
        :scm => 'subversion',
        :deploy_via => ':checkout',
        :scm_username => 'your_SVN_user',
        :scm_password => 'your_SVN_password',
        :user => 'deployment_user(SSH login)',
        :password => 'deployment_user(SSH user) password',
        :runner => 'user to run as with sudo',
        :use_sudo => 'true',
        :deploy_to => '/path/to/deployment_base',
        :repository => 'https://svn.example.com/project/trunk'
      }.freeze
      
      DESC = <<-'EOS'
        Base template that the other templates use to inherit from.
        Defines basic Capistrano configuration parameters.
        Overrides no default Capistrano tasks.
      EOS
      
      TASKS =  <<-'EOS'
         
      EOS
    end
  end
end