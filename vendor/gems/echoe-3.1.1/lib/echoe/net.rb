
require 'net/https'

# Unbreak Rubyforge 1.0.2 on Ruby1.9
class Net::HTTP
  alias :use_ssl= :old_use_ssl=
end
