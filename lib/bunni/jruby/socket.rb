require "bunni/cruby/socket"

module Bunni
  module JRuby
    # TCP socket extension that uses Socket#readpartial to avoid excessive CPU
    # burn after some time. See issue #165.
    # @private
    module Socket
      include Bunni::Socket

      # Reads given number of bytes with an optional timeout
      #
      # @param [Integer] count How many bytes to read
      # @param [Integer] timeout Timeout
      #
      # @return [String] Data read from the socket
      # @api public
      def read_fully(count, timeout = nil)
        return nil if @__bunni_socket_eof_flag__

        value = ''
        begin
          loop do
            value << readpartial(count - value.bytesize)
            break if value.bytesize >= count
          end
        rescue EOFError
          # @eof will break Rubinius' TCPSocket implementation. MK.
          @__bunni_socket_eof_flag__ = true
        rescue *READ_RETRY_EXCEPTION_CLASSES
          if IO.select([self], nil, nil, timeout)
            retry
          else
            raise Timeout::Error, "IO timeout when reading #{count} bytes"
          end
        end
        value
      end # read_fully
    end
  end
end
