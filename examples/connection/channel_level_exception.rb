#!/usr/bin/env ruby
# encoding: utf-8

require "bundler"
Bundler.setup

$:.unshift(File.expand_path("../../../lib", __FILE__))

require 'bunni'

conn = Bunni.new(:heartbeat_interval => 8)
conn.start

begin
  ch1 = conn.create_channel
  ch1.queue_delete("queue_that_should_not_exist#{rand}")
rescue Bunni::NotFound => e
  puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
end


begin
  ch2 = conn.create_channel
  q   = "bunni.examples.recovery.q#{rand}"

  ch2.queue_declare(q, :durable => false)
  ch2.queue_declare(q, :durable => true)
rescue Bunni::PreconditionFailed => e
  puts "Channel-level exception! Code: #{e.channel_close.reply_code}, message: #{e.channel_close.reply_text}"
ensure
  conn.create_channel.queue_delete(q)
end

puts "Disconnecting..."
conn.close
