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

require 'net/ssh/transport/ossl/buffer-factory'
require 'test/unit'

class TC_OSSLBufferFactory < Test::Unit::TestCase

  def setup
    @factory = Net::SSH::Transport::OSSL::BufferFactory.new
  end

  def test_reader
    reader = @factory.reader( "test" )
    assert_instance_of Net::SSH::Transport::OSSL::ReaderBuffer, reader
  end

  def test_reader_interface
    reader = @factory.reader( "test" )
    assert_respond_to reader, :read_key
    assert_respond_to reader, :read_keyblob
    assert_respond_to reader, :read_bignum
  end

  def test_reader_init
    reader = @factory.reader( "test" )
    assert_equal "test", reader.to_s
  end

  def test_buffer
    buffer = @factory.buffer
    assert_instance_of Net::SSH::Transport::OSSL::Buffer, buffer
  end

  def test_buffer_interface
    buffer = @factory.buffer
    assert_respond_to buffer, :read_key
    assert_respond_to buffer, :read_keyblob
    assert_respond_to buffer, :read_bignum
  end

  def test_buffer_init
    buffer = @factory.reader( "test" )
    assert_equal "test", buffer.to_s
  end

  def test_writer_buffer
    buffer = @factory.writer
    assert_instance_of Net::SSH::Util::WriterBuffer, buffer
  end

end
