require "spec_helper"
require "set"

describe Bunni::Queue, "#subscribe_with" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  context "with explicit acknowledgements mode" do
    class ExampleConsumer < Bunni::Consumer
      def cancelled?
        @cancelled
      end

      def handle_cancellation(_)
        @cancelled = true
      end

      def call(delivery_info, metadata, payload)
         # no-op
      end
    end

    # demonstrates that manual acknowledgement mode is actually
    # used. MK.
    it "requeues messages on channel closure" do
      ch1  = connection.create_channel
      ch2  = connection.create_channel
      q1   = ch1.queue("bunni.tests.consumer_object1", :exclusive => true)
      q2   = ch2.queue("bunni.tests.consumer_object1", :exclusive => true)
      ec   = ExampleConsumer.new(ch1, q1, "", false)
      x    = ch2.default_exchange

      t = Thread.new do
        50.times do
          x.publish("hello", :routing_key => q2.name)
        end
      end
      t.abort_on_exception = true

      q1.subscribe_with(ec, :manual_ack => true)
      sleep 2
      ch1.close

      expect(q2.message_count).to eq 50
    end
  end
end
