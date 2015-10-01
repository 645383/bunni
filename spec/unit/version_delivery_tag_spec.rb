require "spec_helper"

require "bunni/concurrent/atomic_fixnum"
require "bunni/versioned_delivery_tag"

describe Bunni::VersionedDeliveryTag, "#stale?" do
  subject { described_class.new(2, 1) }

  context "when delivery tag version < provided version" do
    it "returns true" do
      expect(subject.stale?(2)).to eq true
    end
  end

  context "when delivery tag version = provided version" do
    it "returns false" do
      expect(subject.stale?(1)).to eq false
    end
  end

  context "when delivery tag version > provided version" do
    it "returns true" do
      # this scenario is unrealistic but we still can
      # unit test it. MK.
      expect(subject.stale?(0)).to eq false
    end
  end
end
