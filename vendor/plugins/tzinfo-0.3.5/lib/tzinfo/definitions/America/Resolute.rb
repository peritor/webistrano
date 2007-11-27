require 'tzinfo/timezone_definition'

module TZInfo
  module Definitions
    module America
      module Resolute
        include TimezoneDefinition
        
        timezone 'America/Resolute' do |tz|
          tz.offset :o0, 0, 0, :zzz
          tz.offset :o1, -21600, 0, :CST
          tz.offset :o2, -21600, 7200, :CDDT
          tz.offset :o3, -21600, 3600, :CDT
          tz.offset :o4, -18000, 0, :EST
          
          tz.transition 1947, 8, :o1, 4864857, 2
          tz.transition 1965, 4, :o2, 9755503, 4
          tz.transition 1965, 10, :o1, 9756259, 4
          tz.transition 1980, 4, :o3, 325670400
          tz.transition 1980, 10, :o1, 341391600
          tz.transition 1981, 4, :o3, 357120000
          tz.transition 1981, 10, :o1, 372841200
          tz.transition 1982, 4, :o3, 388569600
          tz.transition 1982, 10, :o1, 404895600
          tz.transition 1983, 4, :o3, 420019200
          tz.transition 1983, 10, :o1, 436345200
          tz.transition 1984, 4, :o3, 452073600
          tz.transition 1984, 10, :o1, 467794800
          tz.transition 1985, 4, :o3, 483523200
          tz.transition 1985, 10, :o1, 499244400
          tz.transition 1986, 4, :o3, 514972800
          tz.transition 1986, 10, :o1, 530694000
          tz.transition 1987, 4, :o3, 544608000
          tz.transition 1987, 10, :o1, 562143600
          tz.transition 1988, 4, :o3, 576057600
          tz.transition 1988, 10, :o1, 594198000
          tz.transition 1989, 4, :o3, 607507200
          tz.transition 1989, 10, :o1, 625647600
          tz.transition 1990, 4, :o3, 638956800
          tz.transition 1990, 10, :o1, 657097200
          tz.transition 1991, 4, :o3, 671011200
          tz.transition 1991, 10, :o1, 688546800
          tz.transition 1992, 4, :o3, 702460800
          tz.transition 1992, 10, :o1, 719996400
          tz.transition 1993, 4, :o3, 733910400
          tz.transition 1993, 10, :o1, 752050800
          tz.transition 1994, 4, :o3, 765360000
          tz.transition 1994, 10, :o1, 783500400
          tz.transition 1995, 4, :o3, 796809600
          tz.transition 1995, 10, :o1, 814950000
          tz.transition 1996, 4, :o3, 828864000
          tz.transition 1996, 10, :o1, 846399600
          tz.transition 1997, 4, :o3, 860313600
          tz.transition 1997, 10, :o1, 877849200
          tz.transition 1998, 4, :o3, 891763200
          tz.transition 1998, 10, :o1, 909298800
          tz.transition 1999, 4, :o3, 923212800
          tz.transition 1999, 10, :o1, 941353200
          tz.transition 2000, 4, :o3, 954662400
          tz.transition 2000, 10, :o4, 972802800
          tz.transition 2001, 4, :o3, 986112000
          tz.transition 2001, 10, :o1, 1004252400
          tz.transition 2002, 4, :o3, 1018166400
          tz.transition 2002, 10, :o1, 1035702000
          tz.transition 2003, 4, :o3, 1049616000
          tz.transition 2003, 10, :o1, 1067151600
          tz.transition 2004, 4, :o3, 1081065600
          tz.transition 2004, 10, :o1, 1099206000
          tz.transition 2005, 4, :o3, 1112515200
          tz.transition 2005, 10, :o1, 1130655600
          tz.transition 2006, 4, :o3, 1143964800
          tz.transition 2006, 10, :o4, 1162105200
        end
      end
    end
  end
end
