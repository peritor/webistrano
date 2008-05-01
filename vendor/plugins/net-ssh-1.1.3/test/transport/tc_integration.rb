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
  require 'net/ssh/transport/services'
  require 'net/ssh/null-host-key-verifier'
  require 'test/unit'

  class TC_Transport_Integration < Test::Unit::TestCase

    def setup
      @registry = Needle::Registry.new :logs => { :device=>STDOUT, :default_level => :WARN }
      @registry.define { |b| b.host_key_verifier { Net::SSH::NullHostKeyVerifier.new } }
      Net::SSH::Transport.register_services( @registry )
    end

    def teardown
      @registry.logs.close
    end

    backends = [ :ossl ]
    keys = [ "ssh-dss", "ssh-rsa" ]
    kexs = [ "diffie-hellman-group-exchange-sha1", "diffie-hellman-group1-sha1" ]
    # we don't test "idea-cbc" because it is not supported by OpenSSH. OpenSSH
    # will use 3des-cbc instead, which we are already testing.
    encryptions = [ "3des-cbc", "aes128-cbc", "blowfish-cbc", "aes256-cbc",
                    "aes192-cbc" ]
    hmacs = [ "hmac-md5", "hmac-sha1", "hmac-md5-96", "hmac-sha1-96" ]
    # for some reason, the version of sshd I'm using locally reports the 'zlib'
    # algorithm as 'zlib@openssh.com', which wreaks havoc on the code. For now,
    # I'm just disabling the zlib tests.
    compressions = [ "none" ] #, "zlib" ]

#    keys = [ 'ssh-dss' ]
#    kexs = [ 'diffie-hellman-group-exchange-sha1' ]
#    encryptions = [ '3des-cbc' ]
#    hmacs = [ 'hmac-md5' ]
#    compressions = [ 'none' ]

    backends.each do |backend|
      keys.each do |key|
        kexs.each do |kex|
          encryptions.each do |encryption|
            hmacs.each do |hmac|
              compressions.each do |compression|
                method_name = "test_#{backend}__#{key}__#{kex}__" +
                              "#{encryption}__#{hmac}__#{compression}"
                method_name.gsub!( /-/, "_" )

                define_method( method_name ) do
                  @registry.define do |b|
                    b.crypto_backend { backend }
                    b.transport_host { "test.host" }
                    b.transport_options do
                      Hash[ :host_key => key,
                            :kex => kex,
                            :encryption => encryption,
                            :hmac => hmac,
                            :compression => compression ]
                    end
                  end

                  session = nil
                  assert_nothing_raised do
                    session = @registry.transport.session
                  end

                  assert_equal key, session.algorithms.host_key
                  assert_equal kex, session.algorithms.kex
                  assert_equal encryption, session.algorithms.encryption_c2s
                  assert_equal encryption, session.algorithms.encryption_s2c
                  assert_equal hmac, session.algorithms.mac_c2s
                  assert_equal hmac, session.algorithms.mac_s2c
                  assert_equal compression, session.algorithms.compression_c2s
                  assert_equal compression, session.algorithms.compression_s2c

                  type = nil
                  assert_nothing_raised do
                    session.send_message(
                      session.class::SERVICE_REQUEST.chr +
                      "\0\0\0\14ssh-userauth" )
                    type, buffer = session.wait_for_message
                  end

                  assert_equal session.class::SERVICE_ACCEPT, type 
                  session.close
                end

              end
            end
          end
        end
      end
    end

  end

end
