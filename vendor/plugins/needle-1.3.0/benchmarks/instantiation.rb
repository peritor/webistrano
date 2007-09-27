$:.unshift "../lib"

require 'benchmark'
require 'needle'

ITERATIONS = 100_000

S = Struct.new( :value )

registry = Needle::Registry.new
registry.register( :immediate, :model=>:prototype ) { S.new }
registry.register( :deferred, :model=>:prototype_deferred ) { S.new }

puts
puts "--------------------------------------------------------------------"
puts "Direct vs. Immediate vs. Deferred instantiation (trivial)"
puts "#{ITERATIONS} iterations"
puts

Benchmark.bm(10) do |x|
  GC.disable
  x.report( "direct:" ) { ITERATIONS.times { S.new } }
  GC.start
  x.report( "immediate:" ) { ITERATIONS.times { registry.immediate } }
  GC.start
  x.report( "deferred:" ) { ITERATIONS.times { registry.deferred } }
  GC.start
  x.report( "deferred*:" ) { ITERATIONS.times { registry.deferred.value } }
  GC.enable
end

puts "* this benchmark forced the proxy to instantiate its wrapped service"
puts

class S2
  def initialize
    @h = Hash.new
    @h[:one] = :two
    @h[:two] = :three
    @h[:three] = :four
    10.times { @h[:one] }
  end

  def value
    @h
  end
end

registry = Needle::Registry.new
registry.register( :immediate, :model=>:prototype ) { S2.new }
registry.register( :deferred, :model=>:prototype_deferred ) { S2.new }

puts
puts "--------------------------------------------------------------------"
puts "Direct vs. Immediate vs. Deferred instantiation (non-trivial)"
puts "#{ITERATIONS} iterations"
puts

Benchmark.bm(10) do |x|
  GC.disable
  x.report( "direct:" ) { ITERATIONS.times { S2.new } }
  GC.start
  x.report( "immediate:" ) { ITERATIONS.times { registry.immediate } }
  GC.start
  x.report( "deferred:" ) { ITERATIONS.times { registry.deferred } }
  GC.start
  x.report( "deferred*:" ) { ITERATIONS.times { registry.deferred.value } }
  GC.enable
end

puts "* this benchmark forced the proxy to instantiate its wrapped service"
puts
