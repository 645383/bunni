# See #165. MK.
if defined?(JRUBY_VERSION)
  require "bunni/jruby/socket"

  module Bunni
    SocketImpl = JRuby::Socket
  end
else
  require "bunni/cruby/socket"

  module Bunni
    SocketImpl = Socket
  end
end
