Webistrano - Capistrano deployment the easy way



About:
  Webistrano is a Web UI for managing Capistrano deployments.
  It lets you manage projects and their stages like test, production, 
  and staging with different settings. Those stages can then
  be deployed with Capistrano through Webistrano.


Installation:

  1. Configuration
  
    Copy config/webistrano_config.rb.sample to config/webistrano_config.rb
    and edit appropriatly. In this configuration file you can set the mail
    settings of Webistrano.
  
  2. Database
  
    Copy config/database.yml.sample to config/database.yml and edit to
    resemble your setting. You need at least the production database.
    The others are optional entries for development and testing.
  
    Then create the database structure with Rake:
  
    > cd webistrano
    > RAILS_ENV=production rake db:migrate
  
  3. Start Webistrano  
  
    > cd webistrano
    > ruby script/server -d -p 3000 -e production
  
    Webistrano is then available at http://host:3000/
  
    The default user is `admin`, the password is `admin`. Please change the password
    after the first login.
  
Author:
  Jonathan Weiss <jw@innerewut.de>
  
License: 
  Code: BSD, see LICENSE.txt
  Images: Right to use in their provided form in Webistrano installations. No other right granted.
