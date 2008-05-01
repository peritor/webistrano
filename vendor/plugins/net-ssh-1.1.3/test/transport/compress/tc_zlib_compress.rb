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

require 'net/ssh/transport/compress/zlib-compressor'
require 'test/unit'

class TC_ZLibCompressor < Test::Unit::TestCase

  def setup
    @compressor = Net::SSH::Transport::Compress::ZLibCompressor.new
  end

  def test_new
    assert_instance_of Net::SSH::Transport::Compress::ZLibCompressor,
      @compressor.new
  end

  def test_compress
    expect = "x\234\n\311WHJ\325Q\310/R\310\313/Q(\201\360J2\022K" +
             "\0242\213\201t\252BaijqIf~\036\000\000\000\377\377"

    assert_equal expect, @compressor.compress( "To be, or not to be, that is the question" )

    expect = "r*-Q(\316O+QT\010\a\311\346d\246g\000\325g\024\345\227\246g(T" +  
             "\346\347\245\244\026)\224g\346\245\344\227+$\025\245&f\027\333" +
             "\003\000\000\000\377\377"

    assert_equal expect, @compressor.compress( "But soft! What light through yonder window breaks?" )
  end

  def test_compress_options
    @compressor.configure :level => 1

    expect = "x\001\n\311WHJ\325Q\310/R\310\313/Q(\201\360J2\022K\0242\213" +
             "\025J2R\025\nKS\213K2\363\363\000\000\000\000\377\377"

    assert_equal expect, @compressor.compress( "To be, or not to be, that is the question" )

    expect = "r*-Q(\316O+QT\010\a\311\346d\246g\000\325g\024\345\227\246g(T" +
             "\346\347\245\244\026)\224g\346\245\344\227+$\025\245&f\027\333" +
             "\003\000\000\000\377\377"

    assert_equal expect, @compressor.compress( "But soft! What light through yonder window breaks?" )
  end

end
