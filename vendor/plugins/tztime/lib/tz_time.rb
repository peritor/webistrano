# ---------------------------------------------------------------------------
# Copyright (c) 2007, 37signals
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ---------------------------------------------------------------------------

# A wrapper class that quacks like a Time instance, but which remembers its
# local time zone. Most operations work like normal, but some will automatically
# convert the object to utc, like #to_s(:db).
class TzTime
  include Comparable

  # Like the Time class, the TzTime class is its own factory. You will almost
  # never create a TzTime instance via +new+. Instead, you will use something
  # like TzTime.now (etc.)
  class <<self
    # Set and access the "local" time zone. There should be a before_filter
    # somewhere in your app that ensures this is set correctly.
    attr_accessor :zone

    # Clears the current zone setting. This should be called from an after_filter
    # to make sure time zones don't leak across requests.
    def reset!
      self.zone = nil
    end

    # Return a TzTime instance that represents the current time.
    def now
      new(zone.utc_to_local(Time.now.utc), zone)
    end

    # Return a TzTime instance for the given arguments, where the arguments
    # are interpreted to be time components in the "local" time zone.
    def local(*args)
      new(Time.utc(*args), zone)
    end

    # Return a TzTime instance for the given arguments, where the arguments
    # are interpreted to be time components in UTC.
    def utc(*args)
      new(zone.utc_to_local(Time.utc(*args)), zone)
    end

    # Given a time instance, return the corresponding TzTime instance. The time
    # is interpreted as being in the "local" time zone, regardless of what the
    # time's actual time zone value is.
    def at(time)
      new(time, zone)
    end

    # Make sure the TzTime class itself responds like the Time class.
    def method_missing(sym, *args, &block)
      result = Time.send(sym, *args, &block)
      result = new(result, zone) if result.is_a?(Time)
      result
    end
  end

  attr_reader :time, :zone
  alias_method :to_time, :time

  # Create a new TzTime instance that wraps the given Time instance. The time
  # is considered to be in the time zone indicated by the +zone+ parameter.
  def initialize(time, zone)
    @time = time.to_time
    @zone = zone
  end

  # Wraps the Time#change method, but returns a TzTime instance for the
  # changed time.
  def change(options) #:nodoc:
    TzTime.new(time.change(options), @zone)
  end

  # Adds some number of seconds to the time, and returns it wrapped in a new
  # TzTime instnace.
  def +(seconds)
    TzTime.new(time + seconds, @zone)
  end

  # Subtracts some number of seconds from the time, and returns it wrapped in
  # a new TzTime instnace.
  def -(seconds)
    TzTime.new(time - seconds, @zone)
  end

  # Returns a Time value, representing the wrapped time in UTC.
  def utc
    @utc ||= zone.local_to_utc(@time)
  end

  # Compares this TzTime with a time instance.
  def <=>(value)
    time.to_time <=> value.to_time
  end

  # This TzTime object always represents the local time in the associated
  # timezone. Thus, #utc? should always return false, unless the zone is the
  # UTC zone.
  def utc?
    zone.name == "UTC"
  end

  # Returns the underlying TZInfo::TimeZonePeriod instance for the wrapped
  # time.
  def period(dst=true)
    t = time
    begin
      @period ||= zone.tzinfo.period_for_local(t, dst)
    rescue TZInfo::PeriodNotFound
      t -= 1.hour
      retry
    end
  end

  # Returns true if the current time is adjusted for daylight savings.
  def dst?
    period.dst?
  end

  # Returns a string repersentation of the time. For the specific case where
  # +mode+ is <tt>:db</tt> or <tt>:rfc822</tt>, this will return the UTC
  # representation of the time. All other conversions will use the local time.
  def to_s(mode = :normal)
    case mode
    when :db, :rfc822 then utc.to_s(mode)
    else time.to_s(mode)
    end
  end

  # Return a reasonable representation of this TzTime object for inspection.
  def inspect
    "#{time.strftime("%Y-%m-%d %H:%M:%S")} #{period.abbreviation}"
  end

  # Because of the method_missing proxy, we want to make sure we report this
  # object as responding to a method as long as the method is defined directly
  # on TzTime, or if the underlying Time instance responds to the method.
  def respond_to?(sym) #:nodoc:
    super || @time.respond_to?(sym)
  end

  # Proxy anything else through to the underlying Time instance.
  def method_missing(sym, *args, &block) #:nodoc:
    result = @time.send(sym, *args, &block)
    result = TzTime.new(result, zone) if result.is_a? Time
    result
  end
end
