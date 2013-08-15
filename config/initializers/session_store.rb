# Be sure to restart your server when you modify this file.

Www::Application.config.session_store :cookie_store, :key => '_www_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Www::Application.config.session_store :active_record_store


# from environment.rb
#config.action_controller.session = {
#    :key    => '_webistrano_session',
#    :secret => WebistranoConfig[:session_secret]
#}
