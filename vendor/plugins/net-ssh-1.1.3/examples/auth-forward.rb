require 'rubygems'

$:.unshift "../lib"
require 'net/ssh'



Net::SSH.start( 'localhost', { :verbose => :debug, :forward_agent => true } ) do |session|
#Net::SSH.start( 'localhost' ) do |session|

  def exec( command )
    lambda do |channel|
      channel.exec command
      channel.on_data do |ch,data|
        ch[:data] ||= ""
        ch[:data] << data
      end
      channel.on_extended_data do |ch,type,data|
        ch[:extended_data] ||= []
        ch[:extended_data][type] ||= ""
        ch[:extended_data][type] << data
      end
    end
  end

  c = session.open_channel( &exec( "ssh -A munkyii.nodnol.org ssh-add -l" ) )

  session.loop

  puts "----------------------------------"
  if c.valid?
    puts c[:data]
    if c[:extended_data] && c[:extended_data][1]
      puts "-- stderr: --"
      puts c[:extended_data][1]
    end
  else
    puts "channel was not opened: #{c.reason} (#{c.reason_code})"
  end

end
