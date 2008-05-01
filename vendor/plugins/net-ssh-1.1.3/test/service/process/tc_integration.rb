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

$:.unshift "#{File.dirname(__FILE__)}/../../../lib"

if $run_integration_tests || __FILE__ == $0

  require 'needle'
  require 'test/unit'
  require 'net/ssh/null-host-key-verifier'

  class TC_Process_Integration < Test::Unit::TestCase

    HOST = "test.host"
    USER = "test"
    PASSWORD = "test/unit"

    def setup
      @registry = Needle::Registry.define(
        :logs => { :device => STDOUT, :default_level => :warn }
      ) do |b|
        b.require 'net/ssh/transport/services', "Net::SSH::Transport"
        b.require 'net/ssh/userauth/services', "Net::SSH::UserAuth"
        b.require 'net/ssh/connection/services', "Net::SSH::Connection"
        b.require 'net/ssh/service/process/services',
          "Net::SSH::Service::Process"
        
        b.crypto_backend { :ossl }
        b.transport_host { HOST }
        b.host_key_verifier { Net::SSH::NullHostKeyVerifier.new }
      end

      @registry.userauth.driver.authenticate( "ssh-connection", USER, PASSWORD )

      @driver = @registry.process.driver
    end

    def teardown
      @registry.transport.session.close
    end

    def test_open_no_block
      script = [ "2+2", "3+2*5", "quit" ]
      expect = [ "4\n", "13\n", :exit ]
      results = []

      process = @driver.open( "bc" )
      process.on_success { |p| p.puts script.shift }
      process.on_stdout do |p,d|
        results << d
        if script.empty?
          p.close_input
        else
          p.puts script.shift
        end
      end
      process.on_exit { results << :exit }

      @registry.connection.driver.loop

      assert_equal expect, results
    end

    def test_open_block
      script = [ "2+2", "3+2*5", "quit" ]
      expect = [ "4\n", "13\n", :exit ]
      results = []

      @driver.open( "bc" ) do |process|
        process.on_success { |p| p.puts script.shift }
        process.on_stdout do |p,d|
          results << d
          if script.empty?
            p.close_input
          else
            p.puts script.shift
          end
        end
        process.on_exit { results << :exit }
      end

      assert_equal expect, results
    end

    def test_popen3_no_block
      stdin, stdout, stderr = @driver.popen3( "bc" )
      stdin.puts "2+2"
      assert_equal "4\n", stdout.read
      stdin.puts "3+2*5"
      assert_equal "13\n", stdout.read
      stdin.puts "quit"
    end

    def test_popen3_block
      @driver.popen3( "bc" ) do |stdin,stdout,stderr|
        stdin.puts "2+2"
        assert_equal "4\n", stdout.read
        stdin.puts "3+2*5"
        assert_equal "13\n", stdout.read
        stdin.puts "quit"
      end
    end

  end

end
