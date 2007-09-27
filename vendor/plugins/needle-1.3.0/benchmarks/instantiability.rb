$:.unshift "../lib"

require 'benchmark'
require 'needle'

ITERATIONS = 100_000

registry = Needle::Registry.new
registry.register( :deferred, :model=>:singleton_deferred ) { Struct.new( :value ).new( 1 ) }
registry.register( :immediate, :model=>:singleton ) { Struct.new( :value ).new( 1 ) }

deferred = registry.deferred
immediate = registry.immediate

puts
puts "--------------------------------------------------------------------"
puts "Proxied method dispatch vs. direct method dispatch"
puts "#{ITERATIONS} iterations"
puts

Benchmark.bm(7) do |x|
  x.report( "proxy:" ) { ITERATIONS.times { deferred.value } }
  x.report( "direct:" ) { ITERATIONS.times { immediate.value } }
end

puts
