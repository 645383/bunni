require "spec_helper"

describe Bunni::Channel, "#recover" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  subject do
    connection.create_channel
  end

  it "is supported" do
    expect(subject.recover(true)).to be_instance_of(AMQ::Protocol::Basic::RecoverOk)
    expect(subject.recover(true)).to be_instance_of(AMQ::Protocol::Basic::RecoverOk)
  end
end
