require "spec_helper"

describe Bunni::Session do
  context "with unreachable host" do
    it "raises Bunni::TCPConnectionFailed" do
      begin
        conn = Bunni.new(:hostname => "192.192.192.192")
        conn.start

        fail "expected 192.192.192.192 to be unreachable"
      rescue Bunni::TCPConnectionFailed => e
      end
    end
  end
end
