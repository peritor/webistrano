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
  require 'net/ssh/connection/services'
  require 'net/ssh/transport/services'
  require 'net/ssh/userauth/services'
  require 'test/unit'

  class TC_Connection_Integration < Test::Unit::TestCase

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
      Net::SSH::Connection.register_services( @registry )

      @registry.define do |b|
        b.crypto_backend { :ossl }
        b.transport_host { HOST }
        b.host_key_verifier { Net::SSH::NullHostKeyVerifier.new }
      end

      @registry[:userauth][:driver].authenticate SERVICE, USER, PASSWORD

      @connection = @registry[:connection][:driver]
    end

    def teardown
      @registry[:transport][:session].close
      @registry.logs.close
    end

    def test_exec
      exec_data = ""
      @connection.open_channel "session" do |chan|
        chan.on_data { |ch,data| exec_data << data }
        chan.exec "echo hello"
      end
      @connection.loop
      assert_equal "hello\n", exec_data
    end

    def test_dialog
      dialog = [ "2+2", "5*10+1", "quit" ]
      results = []
      @connection.open_channel "session" do |chan|
        chan.on_data do |ch,data|
          results << data
          chan.send_data dialog.shift + "\n"
        end
        chan.exec "bc"
        chan.send_data dialog.shift + "\n"
      end
      @connection.loop
      assert_equal [ "4\n", "51\n" ], results
    end

  end

end
