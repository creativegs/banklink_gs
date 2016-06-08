require 'spec_helper'

RSpec.describe Banklink::SebLT::Notification do

  before :all do
    @notification = Banklink::SebLT.notification(SEBLT_RAW_POST)
  end

  context :achnowledgement do
    before :all do
      @notification_with_changed_params = Banklink::SebLT.notification(SEBLT_RAW_POST.gsub('VK_AMOUNT=33', 'VK_AMOUNT=100'))
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

    it "transaction_id should be 123" do
       expect(@notification.transaction_id).to eq "123"
    end

    it "gross should be 33" do
      expect(@notification.gross).to eq "33"
    end
  end

end
