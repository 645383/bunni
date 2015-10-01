#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "bunni"

puts "=> Demonstrating consumer cancellation notification"
puts

conn = Bunni.new
conn.start

ch   = conn.create_channel

module Bunni
  module Examples
    class ExampleConsumer < Bunni::Consumer
      def cancelled?
        @cancelled
      end

      def handle_cancellation(basic_cancel)
        puts "#{@consumer_tag} was cancelled"
        @cancelled = true
      end
    end
  end
end

q    = ch.queue("", :exclusive => true)
c    = Bunni::Examples::ExampleConsumer.new(ch, q)
q.subscribe_with(c)

sleep 0.1
q.delete

sleep 0.1
puts "Disconnecting..."
conn.close
