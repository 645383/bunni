#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "bunni"

conn = Bunni.new
conn.start

ch = conn.create_channel
q  = ch.queue("bunni.examples.hello_world", :auto_delete => true)

q.subscribe do |delivery_info, properties, payload|
  puts "Received #{payload}"
end

q.publish("Hello!", :routing_key => q.name)

sleep 1.0
conn.close
