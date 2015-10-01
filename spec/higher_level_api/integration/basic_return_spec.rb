require "spec_helper"

describe Bunni::Exchange, "#publish" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end


  context "with :mandatory => true and a bad [no routes] routing key" do
    it "causes a message to be returned" do
      ch = connection.create_channel
      x  = ch.default_exchange

      returned = []
      x.on_return do |basic_deliver, properties, content|
        returned << content
      end

      x.publish("xyzzy", :routing_key => rand.to_s, :mandatory => true)
      sleep 0.5

      expect(returned).to include("xyzzy")

      ch.close
    end
  end
end
