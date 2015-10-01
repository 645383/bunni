require "spec_helper"

describe "amq.* exchanges" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  it "are predeclared" do
    ch = connection.create_channel

    ["amq.fanout", "amq.direct", "amq.topic", "amq.match", "amq.headers"].each do |e|
      x = ch.exchange(e)
      expect(x).to be_predeclared
    end

    ch.close
  end
end
