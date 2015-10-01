require "spec_helper"

describe Bunni::Channel, "#open" do
  before :all do
    @connection = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    @connection.start
  end

  after :all do
    @connection.close if @connection.open?
  end


  it "properly resets channel exception state" do
    ch = @connection.create_channel

    begin
      ch.queue("bunni.tests.does.not.exist", :passive => true)
    rescue Bunni::NotFound
      # expected
    end

    # reopen the channel
    ch.open

    # should not raise
    q = ch.queue("bunni.tests.my.queue")
    q.delete
  end
end
