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

require 'net/ssh/transport/compress/zlib-decompressor'
require 'test/unit'

class TC_ZLibDecompressor < Test::Unit::TestCase

  def setup
    @decompressor = Net::SSH::Transport::Compress::ZLibDecompressor.new
  end

  def test_new
    assert_instance_of Net::SSH::Transport::Compress::ZLibDecompressor,
      @decompressor.new
  end

  def test_decompress
    expect = "To be, or not to be, that is the question"

    assert_equal expect, @decompressor.decompress(
      "x\234\n\311WHJ\325Q\310/R\310\313/Q(\201\360J2\022K" +
      "\0242\213\201t\252BaijqIf~\036\000\000\000\377\377" )

    expect = "But soft! What light through yonder window breaks?"

    assert_equal expect, @decompressor.decompress(
      "r*-Q(\316O+QT\010\a\311\346d\246g\000\325g\024\345\227\246g(T" +  
      "\346\347\245\244\026)\224g\346\245\344\227+$\025\245&f\027\333" +
      "\003\000\000\000\377\377" )
  end

end
