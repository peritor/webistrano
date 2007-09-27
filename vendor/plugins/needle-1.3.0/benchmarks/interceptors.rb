$:.unshift "../lib"

require 'benchmark'
require 'needle'

ITERATIONS = 100_000

class TrivialInterceptor
  def initialize( point, parms )
  end

  def process( chain, ctx )
    chain.process_next( ctx )
  end
end

registry = Needle::Registry.new
registry.register( :interceptor ) { TrivialInterceptor }
registry.register( :direct ) { Struct.new( :value ).new }
registry.register( :intercepted_doing ) { Struct.new( :value ).new }
registry.register( :intercepted_with ) { Struct.new( :value ).new }

registry.intercept( :intercepted_doing ).doing { |chain,ctx| chain.process_next(ctx) }
registry.intercept( :intercepted_with ).with { registry.interceptor }

direct = registry.direct
intercepted_doing = registry.intercepted_doing
intercepted_with = registry.intercepted_with

puts
puts "--------------------------------------------------------------------"
puts "Direct method dispatch vs. intercepted method dispatch (trivial)"
puts "#{ITERATIONS} iterations"
puts

Benchmark.bm(20) do |x|
  x.report( "direct:" ) { ITERATIONS.times { direct.value } }
  x.report( "intercepted (doing):" ) { ITERATIONS.times { intercepted_doing.value } }
  x.report( "intercepted (with):" ) { ITERATIONS.times { intercepted_with.value } }
end

puts
