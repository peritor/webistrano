require 'test/unit'
require 'tzinfo_timezone'

class TzinfoTimezoneTest < Test::Unit::TestCase
  TzinfoTimezone::MAPPING.keys.each do |name|
    define_method("test_map_#{name.downcase.gsub(/[^a-z]/, '_')}_to_tzinfo") do
      zone = TzinfoTimezone[name]
      assert_not_nil zone.tzinfo
    end
  end

  TzinfoTimezone.all.each do |zone|
    name = zone.name.downcase.gsub(/[^a-z]/, '_')
    define_method("test_from_#{name}_to_map") do
      assert_not_nil TzinfoTimezone[zone.name]
    end

    define_method("test_utc_offset_for_#{name}") do
      period = zone.tzinfo.period_for_utc(Time.utc(2006,1,1,0,0,0))
      assert_equal period.utc_offset, zone.utc_offset
    end
  end
end
