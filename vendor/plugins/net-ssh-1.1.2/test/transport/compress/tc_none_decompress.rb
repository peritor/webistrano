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

require 'net/ssh/transport/compress/none-decompressor'
require 'test/unit'

class TC_NoneDecompressor < Test::Unit::TestCase

  def setup
    @decompressor = Net::SSH::Transport::Compress::NoneDecompressor.new
  end

  def test_new
    assert_instance_of Net::SSH::Transport::Compress::NoneDecompressor,
      @decompressor.new
  end

  def test_decompress
    expect = "To be, or not to be, that is the question"

    assert_equal expect, @decompressor.decompress(
      "To be, or not to be, that is the question" )

    expect = "But soft! What light through yonder window breaks?"

    assert_equal expect, @decompressor.decompress(
      "But soft! What light through yonder window breaks?" )
  end

end
