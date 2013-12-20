Install and server through passenger with apache

- enable libapache2-mod-passenger (aptitude install libapache2-mod-passenger)
- enable rewrite (a2enmod rewrite)

/etc/apache2/sites-available/webistrano
<VirtualHost *:80>
    ServerName server.example.com
    DocumentRoot /path/to/rails/app/public

	# set passenger root for ubuntu installations
    PassengerRoot /usr/lib/phusion_passenger

    # path to ruby executable
    PassengerRuby /home/vagrant/.rvm/rubies/ruby-1.8.7-p374/bin/ruby

    # endpoint
    RailsBaseURI /

	# rails environment to load
    RailsEnv development
</VirtualHost>

- enable site (a2ensite webistrano)
- restart apache (/etc/init.d apache2 restart)

