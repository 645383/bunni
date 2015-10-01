require "spec_helper"

describe Bunni::Exchange do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  it "binds two existing exchanges" do
    ch          = connection.create_channel

    source      = ch.fanout("bunni.exchanges.source", :auto_delete => true)
    destination = ch.fanout("bunni.exchanges.destination", :auto_delete => true)

    queue       = ch.queue("", :exclusive => true)
    queue.bind(destination)

    destination.bind(source)
    source.publish("")
    sleep 0.5

    expect(queue.message_count).to be > 0

    ch.close
  end
end
