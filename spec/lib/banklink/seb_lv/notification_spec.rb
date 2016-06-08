require 'spec_helper'

RSpec.describe Banklink::SebLV::Notification do

  before :all do
    @notification = Banklink::SebLV.notification(SEBLV_RAW_POST)
  end

  context :achnowledgement do
    before :all do
      @notification_with_changed_params = Banklink::SebLV.notification(SEBLV_RAW_POST.gsub('IB_VERSION=001', 'IB_VERSION=999'))
    end

    #TODO: this still needs to be fixed
    xit "notication should have been acknowledged" do
      expect(@notification.acknowledge).to eq true
    end

    xit "when changed params by hand - it should not be acknowledged" do
      expect(@notification_with_changed_params.acknowledge).to eq false
    end

  end

  context :field_getters do

    it "should be completed" do
      expect(@notification.complete?).to eq true
    end

    it "status should be Completed" do
      expect(@notification.status).to eq "Completed"
    end

    it "transaction_id should be 92" do
       expect(@notification.transaction_id).to eq "92"
    end

    # TODO: check why post has no gross / amounts etc
    it "gross should be nil" do
      expect(@notification.gross).to eq nil
    end
  end

end
