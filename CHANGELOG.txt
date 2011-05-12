
edge

* Add Unicorn template [vongrippen]

* Update to Rails 2.3.11 and Capistrano 2.6.0

* Switch to Bundler based deployment

* Add some missing indices

* Allow to prefill the deployment descirption, see https://github.com/peritor/webistrano/issues/12 [tomfotherby]

* Update to Rails 2.3.5

* When cloning, also clone roles. Provided by Sergio Cambra.

* Update to Rails 2.3.4

* Users cannot be directly deleted anymore. They are disabled in order to not break references and keep the correct history.
  If you really want to delete a user you have to resort to the script/console or SQL for now. Fixes ticket #110.

* Move gems to vendor/gems and update Capistrano to 2.5.5 and Net::SSH to 2.0.11

* Update Rails to 2.2.2

* Add support to lookup configuration parameters in the definition of configuration parameters:
  set :foo, "123"
  set :bar, "a #{foo} here"
  
  Only works for configuration parameter (build-in like release_path or your own). DOES NOT EXECUTE CODE  

* Add Hash type to variables. Provided by sergio@entrecables.com #103

* Add locking. A running deployment locks the stage, so that no other deployment ca be run. Overridable by checkbox.

* Update Net::SSH to 2.0.10 and Capistrano to 2.5.4

* Add Thin template for Rails. Provided by Richard Piacentini

1.4

* Added CAS-auth support. Provided by Tim Shadel.

* Auto-scroll deployment log

* Ability to cancel running deployments. Refactor deployment status.

* Show recent deployments on the project page

* A deployment comment is no longer required, it is optional from now on

* Track deployed revisions

* Rename 'www' role to 'web' to match Capistrano, #91 by sergio@entrecables.com

* Support array values for configuration paramters, #93 by paradise

* Update Capistrano to 2.5.0

* Update to Rails 2.1.1

* Allow to clone a project. Stages and configuration is cloned for now. Closes #85

* Add Recipe versioning with version_fu. Provided by Mathias Meyer

* Add /projects/1/stages/1/deployments/latest. Provided by Mathias Meyer

* Fix XML output of stage tasks. Provided by Mathias Meyer

* Add version info XML action. Provided by Mathias Meyer

* Update Net::SSH to 1.1.3

1.3

* Add support for mod_rails / Phusion Passenger. Use mod_rails as project type.

* Ability to disable host per deloy. This way host that are down do not block a deployment

* Check syntax of recipes. Provided by Mathias Meyer

* Ajax-Preview on recipe edit. Provided by Mathias Meyer

* Update Capistrano to 2.2.0 and Net::SFTP to 1.1.1

* Better handling of `repeat` task by also repeating the description

* Moved ActionController session key to webistrano_config.rb

* Used template naming conventions of Rails 2.x: Provided by kosmas.schuetz@gmx.com
    *.rhtml => *.html.erb
    *.rjs => *.js.rjs 
    
* Updated to Prototype 1.6

* Add script/deploy Ruby script to deploy from the command line, provided by Peter J Jones <pjones@pmade.com>

* Update included Rails version to 2.0.2

* Add tztime and give each user a time zone

* Introduce a 5 second sleep between mongrel stop and start while restarting'

* Only admins can manage projects, recipes, hosts, and users. Normal users can only view.

* Show also all recent deployments in dashboard

* Rename deployments DB column to description in order to prevent Oracle crash, fix #17

* Delete the cached stylesheet on server boot

* A stage can list all available tasks [schacon@gmail.com]

1.2

* By default Webistrano will allocate a pty in contrast to Capistrano 2.1.0

* Add git support with Capistrano 2.1.0

* Add Capistrano 2.1.0

* Add experimental support for ssh_keys and ssh_ports as normal configuration parameter.
  Currently only one SSH key is supported.

* Highlight recipe syntax with syntax gem.

* Distinguish roles also by ssh_port, so that multiple roles with the same IP
  but different SSH ports will be accepted. Provided by Al Evans.

* Add no_symlink attribute to role. Provided by Al Evans.

1.1

* Multiple UI fixes and enhancements

* Moved recipes from project level to stage level. So multiple stages can share recipes. 

* Updated included net-ssh to 1.1.2

1.0
