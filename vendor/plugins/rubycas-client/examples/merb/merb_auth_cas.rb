# run very flat apps with merb -I <app file>.

# Uncomment for DataMapper ORM
# use_orm :datamapper

# Uncomment for ActiveRecord ORM
# use_orm :activerecord

# Uncomment for Sequel ORM
# use_orm :sequel

$:.unshift(File.dirname(__FILE__) / ".." / ".." / "lib")
require "casclient"
require 'casclient/frameworks/merb/filter'
#
# ==== Pick what you test with
#

# This defines which test framework the generators will use.
# RSpec is turned on by default.
#
# To use Test::Unit, you need to install the merb_test_unit gem.
# To use RSpec, you don't have to install any additional gems, since
# merb-core provides support for RSpec.
#
# use_test :test_unit
use_test :rspec

#
# ==== Choose which template engine to use by default
#

# Merb can generate views for different template engines, choose your favourite as the default.

use_template_engine :erb
# use_template_engine :haml

Merb::Config.use { |c|
  c[:framework]           = { :public => [Merb.root / "public", nil] }
  c[:session_store]       = 'cookie'
  c[:exception_details]   = true
  c[:log_level]           = :debug # or error, warn, info or fatal
  c[:log_stream]          = STDOUT
  c[:session_secret_key]  = '9f30c015f2132d217bfb81e31668a74fadbdf672'
  c[:log_file]            = Merb.root / "log" / "merb.log"

  c[:reload_classes]   = true
  c[:reload_templates] = true
}


Merb::Plugins.config[:"rubycas-client"] = {
  :cas_base_url => "http://localhost:7777"
}

Merb::Router.prepare do
  match('/').to(:controller => 'merb_auth_cas', :action =>'index').name(:default)
end

class MerbAuthCas < Merb::Controller
  include CASClient::Frameworks::Merb::Filter
  before :cas_filter

  def index
    "Hi, #{session[:cas_user]}"
  end
end
