#--
# =============================================================================
# Copyright (c) 2004, Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SFTP Secure FTP Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SFTP
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-sftp website: http://net-ssh.rubyforge.org/sftp
# project website : http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

$:.unshift "../../../lib"
$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require 'net/sftp/protocol/05/impl'
require '04/tc_impl'

class TC_05_Impl < TC_04_Impl

  def impl_class
    Net::SFTP::Protocol::V_05::Impl
  end

  unless defined?( IO_FLAGS_V4 )
    IO_FLAGS_V4 = [ IO::RDONLY, IO::WRONLY, IO::RDWR, IO::APPEND ]
    OTHER_FLAGS_V4 = [ 0, IO::CREAT, IO::TRUNC, IO::EXCL ]
    FLAG_MAP_V4 = { IO::RDONLY => 2, IO::WRONLY => 1, IO::RDWR => 3,
      IO::APPEND => 11, IO::CREAT => 3, IO::TRUNC => 4 }
    ACCESS_MAP_V4 = { IO::RDONLY => 0x81, IO::WRONLY => 0x102,
      IO::RDWR => 0x183, IO::APPEND => 0x106 }

    IO_FLAGS_V4.each do |flag|
      OTHER_FLAGS_V4.each do |oflag|
        [ nil, 0400 ].each do |mode|
          define_method( "test_open_#{flag}_#{oflag}_#{mode||"nil"}" ) do
            return if oflag == IO::EXCL
            @assistant.mock_handle( :open ) { |*a| [ a[0], a[1..-1] ] }
            args = [ 14, "a path", flag | oflag ]
            args << mode if mode
            assert_equal 14, @impl.open( *args )
            assert_equal 1, @assistant.mock_count( :open )
            assert_equal( ( mode || 0660 ), @permissions )
            sftp_flag = FLAG_MAP_V4[flag] |
              ( oflag == 0 ? 0 : FLAG_MAP_V4[oflag] )
            access_flag = ACCESS_MAP_V4[flag]
            assert_equal Net::SFTP::Protocol::Constants::FXP_OPEN,
              @sent_data.first[0]
            assert_equal [ "a path", access_flag, sftp_flag ],
              @sent_data.first[1][0,3]
          end
        end
      end
    end
  end

end
