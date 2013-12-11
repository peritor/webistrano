if WebistranoConfig[:authentication_method] == :cas
  cas_options = YAML::load_file(Rails.root.to_s+'/config/cas.yml')
  CASClient::Frameworks::Rails::Filter.configure(cas_options[Rails.env])
end

WEBISTRANO_VERSION = '1.5 - JS 1.0'

ActionMailer::Base.delivery_method = WebistranoConfig[:smtp_delivery_method] 
ActionMailer::Base.smtp_settings = WebistranoConfig[:smtp_settings] 

Notification.webistrano_sender_address = WebistranoConfig[:webistrano_sender_address]