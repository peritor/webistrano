# This file makes it possible to install RubyCAS-Client as a Rails plugin.

$: << File.expand_path(File.dirname(__FILE__))+'/lib'

require 'casclient'
require 'casclient/frameworks/rails/filter'