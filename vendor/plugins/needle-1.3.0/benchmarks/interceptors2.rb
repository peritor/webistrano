$:.unshift "../lib"

require 'benchmark'
require 'needle'

ITERATIONS = 10_000

class UnloggedBeast
  def value( p1, p2 )
    [ p1, p2 ]
  end
end

class LoggedBeast < UnloggedBeast
  attr_writer :log

  def value( p1, p2 )
    @log.debug( "value(#{p1.inspect}, #{p2.inspect})" ) if @log.debug?
    result = super
    @log.debug( "value(...) => #{result.inspect}" ) if @log.debug?
    return result
  rescue Exception => e
    @log.debug( "value(...) raised #{e.message.inspect} (#{e.class})" ) if @log.debug?
    raise
  end
end

registry = Needle::Registry.new( :logs=> { :filename=>"/dev/null" } )
registry.register( :direct ) do
  beast = LoggedBeast.new
  beast.log = registry.logs.get( "direct" )
  beast
end

registry.register( :intercepted_doing ) { UnloggedBeast.new }
registry.register( :intercepted_with ) { UnloggedBeast.new }

registry.intercept( :intercepted_doing ).
  with_options( :log => registry.logs.get( "doing" ) ).
  doing do |chain,ctx|
    log = ctx.data[:options][:log]
    begin
      log.debug( "#{ctx.sym}(#{ctx.args.map{|i|i.inspect}.join(",")})" ) if log.debug?
      result = chain.process_next(ctx)
      log.debug( "#{ctx.sym}(...) => #{result.inspect}" ) if log.debug?
      result
    rescue Exception 
      log.debug( "value(...) raised #{e.message.inspect} (#{e.class})" ) if log.debug?
    end
  end

registry.intercept( :intercepted_with ).with { registry.logging_interceptor }

direct = registry.direct
intercepted_doing = registry.intercepted_doing
intercepted_with = registry.intercepted_with

puts
puts "--------------------------------------------------------------------"
puts "Direct method dispatch vs. intercepted method dispatch (non-trivial)"
puts "#{ITERATIONS} iterations"
puts

Benchmark.bm(20) do |x|
  x.report( "direct:" ) { ITERATIONS.times { direct.value( :a, :b ) } }
  x.report( "intercepted (doing):" ) { ITERATIONS.times { intercepted_doing.value( :a, :b ) } }
  x.report( "intercepted (with):" ) { ITERATIONS.times { intercepted_with.value( :a, :b ) } }
end

puts
