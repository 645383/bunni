#!/usr/bin/env ruby
# encoding: utf-8

require "bundler"
Bundler.setup

$:.unshift(File.expand_path("../../../lib", __FILE__))

require 'bunni'

begin
  conn = Bunni.new("amqp://guest:guest@aksjhdkajshdkj.example82737.com")
  conn.start
rescue Bunni::TCPConnectionFailed => e
  puts "Connection to #{conn.hostname} failed"
end
