# See #165. MK.
if defined?(JRUBY_VERSION)
  require "bunni/jruby/ssl_socket"

  module Bunni
    SSLSocketImpl = JRuby::SSLSocket
  end
else
  require "bunni/cruby/ssl_socket"

  module Bunni
    SSLSocketImpl = SSLSocket
  end
end
