#--
# =============================================================================
# Copyright (c) 2004,2005 Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SSH Secure Shell Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SSH
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-ssh website : http://net-ssh.rubyforge.org
# project website: http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

if $run_integration_tests || __FILE__ == $0

  require 'needle'
  require 'net/ssh/null-host-key-verifier'
  require 'net/ssh/transport/services'
  require 'net/ssh/userauth/services'
  require 'test/unit'

  class TC_UserAuth_Integration < Test::Unit::TestCase

    HOST = "test.host"
    USER = "test"
    PASSWORD = "test/unit"
    SERVICE = "ssh-connection"

    def setup
      @registry = Needle::Registry.new(
        :logs => { :device=>STDOUT, :default_level => :WARN }
      )

      Net::SSH::Transport.register_services( @registry )
      Net::SSH::UserAuth.register_services( @registry )

      @registry.define do |b|
        b.crypto_backend { :ossl }
        b.transport_host { HOST }
        b.host_key_verifier { Net::SSH::NullHostKeyVerifier.new }
      end

      @userauth = @registry[:userauth][:driver]
    end

    def teardown
      @registry[:transport][:session].close
      @registry.logs.close
    end

    def test_keyboard_interactive
      @userauth.set_auth_method_order "keyboard-interactive"

      called = 0
      @registry.userauth[:methods].define.keyboard_interactive_callback do |c,p|
        proc do |req|
          called += 1
          if req.prompts.length > 0
            [ req.password ]
          else
            []
          end
        end
      end

      assert @userauth.authenticate( SERVICE, USER, PASSWORD )
      assert_equal 2, called
    end

    def test_password
      @userauth.set_auth_method_order "password"
      assert @userauth.authenticate( SERVICE, USER, PASSWORD )
    end

    def test_password_bad
      @userauth.set_auth_method_order "password"
      assert !@userauth.authenticate( SERVICE, USER, PASSWORD + 'K' )
    end

    def test_publickey_bad
      @userauth.set_auth_method_order "publickey"
      assert !@userauth.authenticate( SERVICE, USER )
    end

    def test_hostbased_bad
      @userauth.set_auth_method_order "hostbased"
      assert !@userauth.authenticate( SERVICE, USER )
    end

  end

end
