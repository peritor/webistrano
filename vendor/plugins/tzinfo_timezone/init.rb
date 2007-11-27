require 'tzinfo_timezone'

# remove the existing TimeZone constant
Object.send(:remove_const, :TimeZone)

# Use TzinfoTimezone as the TimeZone class
Object::TimeZone = TzinfoTimezone