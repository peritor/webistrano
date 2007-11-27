require 'tzinfo/timezone_definition'

module TZInfo
  module Definitions
    module Indian
      module Mauritius
        include TimezoneDefinition
        
        timezone 'Indian/Mauritius' do |tz|
          tz.offset :o0, 13800, 0, :LMT
          tz.offset :o1, 14400, 0, :MUT
          
          tz.transition 1906, 12, :o1, 348130993, 144
        end
      end
    end
  end
end
