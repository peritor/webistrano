require 'tzinfo/timezone_definition'

module TZInfo
  module Definitions
    module Asia
      module Baghdad
        include TimezoneDefinition
        
        timezone 'Asia/Baghdad' do |tz|
          tz.offset :o0, 10660, 0, :LMT
          tz.offset :o1, 10656, 0, :BMT
          tz.offset :o2, 10800, 0, :AST
          tz.offset :o3, 10800, 3600, :ADT
          
          tz.transition 1889, 12, :o1, 10417111387, 4320
          tz.transition 1917, 12, :o2, 726478313, 300
          tz.transition 1982, 4, :o3, 389048400
          tz.transition 1982, 9, :o2, 402264000
          tz.transition 1983, 3, :o3, 417906000
          tz.transition 1983, 9, :o2, 433800000
          tz.transition 1984, 3, :o3, 449614800
          tz.transition 1984, 9, :o2, 465422400
          tz.transition 1985, 3, :o3, 481150800
          tz.transition 1985, 9, :o2, 496792800
          tz.transition 1986, 3, :o3, 512517600
          tz.transition 1986, 9, :o2, 528242400
          tz.transition 1987, 3, :o3, 543967200
          tz.transition 1987, 9, :o2, 559692000
          tz.transition 1988, 3, :o3, 575416800
          tz.transition 1988, 9, :o2, 591141600
          tz.transition 1989, 3, :o3, 606866400
          tz.transition 1989, 9, :o2, 622591200
          tz.transition 1990, 3, :o3, 638316000
          tz.transition 1990, 9, :o2, 654645600
          tz.transition 1991, 4, :o3, 670464000
          tz.transition 1991, 10, :o2, 686275200
          tz.transition 1992, 4, :o3, 702086400
          tz.transition 1992, 10, :o2, 717897600
          tz.transition 1993, 4, :o3, 733622400
          tz.transition 1993, 10, :o2, 749433600
          tz.transition 1994, 4, :o3, 765158400
          tz.transition 1994, 10, :o2, 780969600
          tz.transition 1995, 4, :o3, 796694400
          tz.transition 1995, 10, :o2, 812505600
          tz.transition 1996, 4, :o3, 828316800
          tz.transition 1996, 10, :o2, 844128000
          tz.transition 1997, 4, :o3, 859852800
          tz.transition 1997, 10, :o2, 875664000
          tz.transition 1998, 4, :o3, 891388800
          tz.transition 1998, 10, :o2, 907200000
          tz.transition 1999, 4, :o3, 922924800
          tz.transition 1999, 10, :o2, 938736000
          tz.transition 2000, 4, :o3, 954547200
          tz.transition 2000, 10, :o2, 970358400
          tz.transition 2001, 4, :o3, 986083200
          tz.transition 2001, 10, :o2, 1001894400
          tz.transition 2002, 4, :o3, 1017619200
          tz.transition 2002, 10, :o2, 1033430400
          tz.transition 2003, 4, :o3, 1049155200
          tz.transition 2003, 10, :o2, 1064966400
          tz.transition 2004, 4, :o3, 1080777600
          tz.transition 2004, 10, :o2, 1096588800
          tz.transition 2005, 4, :o3, 1112313600
          tz.transition 2005, 10, :o2, 1128124800
          tz.transition 2006, 4, :o3, 1143849600
          tz.transition 2006, 10, :o2, 1159660800
          tz.transition 2007, 4, :o3, 1175385600
          tz.transition 2007, 10, :o2, 1191196800
          tz.transition 2008, 4, :o3, 1207008000
          tz.transition 2008, 10, :o2, 1222819200
          tz.transition 2009, 4, :o3, 1238544000
          tz.transition 2009, 10, :o2, 1254355200
          tz.transition 2010, 4, :o3, 1270080000
          tz.transition 2010, 10, :o2, 1285891200
          tz.transition 2011, 4, :o3, 1301616000
          tz.transition 2011, 10, :o2, 1317427200
          tz.transition 2012, 4, :o3, 1333238400
          tz.transition 2012, 10, :o2, 1349049600
          tz.transition 2013, 4, :o3, 1364774400
          tz.transition 2013, 10, :o2, 1380585600
          tz.transition 2014, 4, :o3, 1396310400
          tz.transition 2014, 10, :o2, 1412121600
          tz.transition 2015, 4, :o3, 1427846400
          tz.transition 2015, 10, :o2, 1443657600
          tz.transition 2016, 4, :o3, 1459468800
          tz.transition 2016, 10, :o2, 1475280000
          tz.transition 2017, 4, :o3, 1491004800
          tz.transition 2017, 10, :o2, 1506816000
          tz.transition 2018, 4, :o3, 1522540800
          tz.transition 2018, 10, :o2, 1538352000
          tz.transition 2019, 4, :o3, 1554076800
          tz.transition 2019, 10, :o2, 1569888000
          tz.transition 2020, 4, :o3, 1585699200
          tz.transition 2020, 10, :o2, 1601510400
          tz.transition 2021, 4, :o3, 1617235200
          tz.transition 2021, 10, :o2, 1633046400
          tz.transition 2022, 4, :o3, 1648771200
          tz.transition 2022, 10, :o2, 1664582400
          tz.transition 2023, 4, :o3, 1680307200
          tz.transition 2023, 10, :o2, 1696118400
          tz.transition 2024, 4, :o3, 1711929600
          tz.transition 2024, 10, :o2, 1727740800
          tz.transition 2025, 4, :o3, 1743465600
          tz.transition 2025, 10, :o2, 1759276800
          tz.transition 2026, 4, :o3, 1775001600
          tz.transition 2026, 10, :o2, 1790812800
          tz.transition 2027, 4, :o3, 1806537600
          tz.transition 2027, 10, :o2, 1822348800
          tz.transition 2028, 4, :o3, 1838160000
          tz.transition 2028, 10, :o2, 1853971200
          tz.transition 2029, 4, :o3, 1869696000
          tz.transition 2029, 10, :o2, 1885507200
          tz.transition 2030, 4, :o3, 1901232000
          tz.transition 2030, 10, :o2, 1917043200
          tz.transition 2031, 4, :o3, 1932768000
          tz.transition 2031, 10, :o2, 1948579200
          tz.transition 2032, 4, :o3, 1964390400
          tz.transition 2032, 10, :o2, 1980201600
          tz.transition 2033, 4, :o3, 1995926400
          tz.transition 2033, 10, :o2, 2011737600
          tz.transition 2034, 4, :o3, 2027462400
          tz.transition 2034, 10, :o2, 2043273600
          tz.transition 2035, 4, :o3, 2058998400
          tz.transition 2035, 10, :o2, 2074809600
          tz.transition 2036, 4, :o3, 2090620800
          tz.transition 2036, 10, :o2, 2106432000
          tz.transition 2037, 4, :o3, 2122156800
          tz.transition 2037, 10, :o2, 2137968000
          tz.transition 2038, 4, :o3, 4931029, 2
          tz.transition 2038, 10, :o2, 4931395, 2
          tz.transition 2039, 4, :o3, 4931759, 2
          tz.transition 2039, 10, :o2, 4932125, 2
          tz.transition 2040, 4, :o3, 4932491, 2
          tz.transition 2040, 10, :o2, 4932857, 2
          tz.transition 2041, 4, :o3, 4933221, 2
          tz.transition 2041, 10, :o2, 4933587, 2
          tz.transition 2042, 4, :o3, 4933951, 2
          tz.transition 2042, 10, :o2, 4934317, 2
          tz.transition 2043, 4, :o3, 4934681, 2
          tz.transition 2043, 10, :o2, 4935047, 2
          tz.transition 2044, 4, :o3, 4935413, 2
          tz.transition 2044, 10, :o2, 4935779, 2
          tz.transition 2045, 4, :o3, 4936143, 2
          tz.transition 2045, 10, :o2, 4936509, 2
          tz.transition 2046, 4, :o3, 4936873, 2
          tz.transition 2046, 10, :o2, 4937239, 2
          tz.transition 2047, 4, :o3, 4937603, 2
          tz.transition 2047, 10, :o2, 4937969, 2
          tz.transition 2048, 4, :o3, 4938335, 2
          tz.transition 2048, 10, :o2, 4938701, 2
          tz.transition 2049, 4, :o3, 4939065, 2
          tz.transition 2049, 10, :o2, 4939431, 2
          tz.transition 2050, 4, :o3, 4939795, 2
          tz.transition 2050, 10, :o2, 4940161, 2
        end
      end
    end
  end
end
