require "spec_helper"

describe Bunni::Queue, "#delete" do
  let(:connection) do
    c = Bunni.new(:user => "bunni_gem", :password => "bunni_password", :vhost => "bunni_testbed")
    c.start
    c
  end

  after :each do
    connection.close
  end



  context "with a name of an existing queue" do
    it "deletes that queue" do
      ch = connection.create_channel
      q  = ch.queue("")

      q.delete
      # no exception as of RabbitMQ 3.2. MK.
      q.delete

      expect(ch.queues.size).to eq 0
    end
  end


  context "with a name of an existing queue" do
    it "DOES NOT raise an exception" do
      ch = connection.create_channel

      # no exception as of RabbitMQ 3.2. MK.
      ch.queue_delete("sdkhflsdjflskdjflsd#{rand}")
      ch.queue_delete("sdkhflsdjflskdjflsd#{rand}")
      ch.queue_delete("sdkhflsdjflskdjflsd#{rand}")
      ch.queue_delete("sdkhflsdjflskdjflsd#{rand}")
    end
  end
end
