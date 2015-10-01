require "spec_helper"

describe Bunni::Channel, "#confirm_select" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close if connection.open?
  end

  it "is supported" do
    connection.with_channel do |ch|
      ch.confirm_select
    end
  end
end
