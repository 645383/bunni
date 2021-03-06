require "spec_helper"

describe Bunni::Consumer, "#cancel" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  context "with a non-blocking consumer" do
    let(:queue_name) { "bunni.queues.#{rand}" }

    it "cancels the consumer" do
      delivered_data = []

      t = Thread.new do
        ch         = connection.create_channel
        q          = ch.queue(queue_name, :auto_delete => true, :durable => false)
        consumer = q.subscribe(:block => false) do |_, _, payload|
          delivered_data << payload
        end

        expect(consumer.consumer_tag).not_to be_nil
        cancel_ok = consumer.cancel
        expect(cancel_ok.consumer_tag).to eq consumer.consumer_tag

        ch.close
      end
      t.abort_on_exception = true
      sleep 0.5

      ch = connection.create_channel
      ch.default_exchange.publish("", :routing_key => queue_name)

      sleep 0.7
      expect(delivered_data).to be_empty
    end
  end


  context "with a blocking consumer" do
    let(:queue_name) { "bunni.queues.#{rand}" }

    it "cancels the consumer" do
      delivered_data = []
      consumer       = nil

      t = Thread.new do
        ch         = connection.create_channel
        q          = ch.queue(queue_name, :auto_delete => true, :durable => false)

        consumer   = Bunni::Consumer.new(ch, q)
        consumer.on_delivery do |_, _, payload|
          delivered_data << payload
        end

        q.subscribe_with(consumer, :block => false)
      end
      t.abort_on_exception = true
      sleep 1.0

      consumer.cancel
      sleep 1.0

      ch = connection.create_channel
      ch.default_exchange.publish("", :routing_key => queue_name)

      sleep 0.7
      expect(delivered_data).to be_empty
    end
  end
end
