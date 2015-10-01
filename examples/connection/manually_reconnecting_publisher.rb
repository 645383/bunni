#!/usr/bin/env ruby
require 'bunni'

Bundler.setup

begin
  connection = Bunni.new(:automatically_recover => false)
  connection.start

  ch = connection.channel
  x  = ch.default_exchange

  loop do
    10.times do |i|
      print "."
      x.publish("")
    end

    sleep 3.0
  end
rescue Bunni::NetworkFailure => e
  ch.maybe_kill_consumer_work_pool!

  sleep 10
  puts "Recovering manually..."

  retry
end
