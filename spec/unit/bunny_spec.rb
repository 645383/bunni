require "spec_helper"

describe Bunni do
  it "has library version" do
    expect(Bunni::VERSION).not_to be_nil
    expect(Bunni.version).not_to be_nil
  end


  it "has AMQP protocol version" do
    expect(Bunni::PROTOCOL_VERSION).to eq "0.9.1"
    expect(AMQ::Protocol::PROTOCOL_VERSION).to eq "0.9.1"
    expect(Bunni.protocol_version).to eq "0.9.1"
  end
end
