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

$:.unshift "#{File.dirname(__FILE__)}/../lib"

if $run_integration_tests || __FILE__ == $0

  require 'net/ssh/session'
  require 'test/unit'

  class TC_Integration < Test::Unit::TestCase

    HOST = "test.host"
    USER = "test"
    PASSWORD = "test/unit"
    SESS_OPTS = {
      :registry_options => {
        :logs => {
          :device => STDOUT,
          :default_level => :warn
        }
      },
      :paranoid => false
    }

    def setup
      @session = Net::SSH::Session.new( HOST, USER, PASSWORD, SESS_OPTS )
    end

    def teardown
      @session.close
    end

    def test_no_auth
      assert_raise( Net::SSH::AuthenticationFailed ) do
        Net::SSH::Session.new( HOST, USER, PASSWORD+"K", SESS_OPTS )
      end
    end

    def test_exec
      exec_data = ""
      @session.open_channel do |chan|
        chan.on_data { |ch,data| exec_data << data }
        chan.exec "echo hello"
      end
      @session.loop
      assert_equal "hello\n", exec_data
    end

    def test_dialog
      dialog = [ "2+2", "5*10+1", "quit" ]
      results = []
      @session.open_channel "session" do |chan|
        chan.on_data do |ch,data|
          results << data
          chan.send_data dialog.shift + "\n"
        end
        chan.exec "bc"
        chan.send_data dialog.shift + "\n"
      end
      @session.loop
      assert_equal [ "4\n", "51\n" ], results
    end

  end

end
