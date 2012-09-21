module Webistrano
  module Template
    module Jaguar
      CONFIG = {
        :application => 'your_app_name',
        :branch      => 'master',
        :scm         => 'git',
        :deploy_via  => ':remote_cache',
        :user        => 'deployer',
        :use_sudo    => 'false',
        :deploy_to   => '/srv/www',
        :repository  => 'bitbucket:jaguar/repo'
      }.freeze
      
      DESC = <<-'EOS'
        Base template that the other templates use to inherit from.
        Defines basic Capistrano configuration parameters.
        Overrides no default Capistrano tasks.
      EOS
      
      TASKS =  <<-'EOS'
        # allocate a pty by default as some systems have problems without
        default_run_options[:pty] = true
      
        # set Net::SSH ssh options through normal variables
        # at the moment only one SSH key is supported as arrays are not
        # parsed correctly by Webistrano::Deployer.type_cast (they end up as strings)
        [:ssh_port, :ssh_keys].each do |ssh_opt|
          if exists? ssh_opt
            logger.important("SSH options: setting #{ssh_opt} to: #{fetch(ssh_opt)}")
            ssh_options[ssh_opt.to_s.gsub(/ssh_/, '').to_sym] = fetch(ssh_opt)
          end
        end
      EOS
    end
  end
end
