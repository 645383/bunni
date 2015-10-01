# -*- encoding: utf-8; mode: ruby -*-

require "timeout"

require "bunni/version"
require "amq/protocol/client"
require "amq/protocol/extensions"

require "bunni/framing"
require "bunni/exceptions"

require "bunni/socket"

require "bunni/timeout"

begin
  require "openssl"

  require "bunni/ssl_socket"
rescue LoadError
  # no-op
end

require "logger"

# Core entities: connection, channel, exchange, queue, consumer
require "bunni/session"
require "bunni/channel"
require "bunni/exchange"
require "bunni/queue"
require "bunni/consumer"

# Bunni is a RabbitMQ client that focuses on ease of use.
# @see http://rubybunni.info
module Bunni
  # AMQP protocol version Bunni implements
  PROTOCOL_VERSION = AMQ::Protocol::PROTOCOL_VERSION

  #
  # API
  #

  # @return [String] Bunni version
  def self.version
    VERSION
  end

  # @return [String] AMQP protocol version Bunni implements
  def self.protocol_version
    AMQ::Protocol::PROTOCOL_VERSION
  end

  # Instantiates a new connection. The actual network
  # connection is started with {Bunni::Session#start}
  #
  # @return [Bunni::Session]
  # @see Bunni::Session#start
  # @see http://rubybunni.info/articles/getting_started.html
  # @see http://rubybunni.info/articles/connecting.html
  # @api public
  def self.new(connection_string_or_opts = {}, opts = {}, &block)
    if connection_string_or_opts.respond_to?(:keys) && opts.empty?
      opts = connection_string_or_opts
    end

    conn = Session.new(connection_string_or_opts, opts)
    @default_connection ||= conn

    conn
  end


  def self.run(connection_string_or_opts = {}, opts = {}, &block)
    raise ArgumentError, 'Bunni#run requires a block' unless block

    client = Session.new(connection_string_or_opts, opts)

    begin
      client.start
      block.call(client)
    ensure
      client.stop
    end

    # backwards compatibility
    :run_ok
  end
end
