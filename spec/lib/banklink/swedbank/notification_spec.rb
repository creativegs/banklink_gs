require 'spec_helper'

RSpec.describe Banklink::Swedbank::Notification do

  before :all do
    @notification = Banklink::Swedbank.notification(SWEDBANK_RAW_POST)
  end

  context :achnowledgement do
    before :all do
      @notification_with_changed_params = Banklink::Swedbank.notification(SWEDBANK_RAW_POST.gsub('VK_AMOUNT=33', 'VK_AMOUNT=100'))
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
    it "amount should be in cents 3300" do
      expect(@notification.amount).to eq 3300
    end

    it "should be completed" do
      expect(@notification.complete?).to eq true
    end

    it "status should be Completed" do
      expect(@notification.status).to eq "Completed"
    end

    it "item id should be 88" do
      expect(@notification.item_id).to eq "88"
    end

    it "transaction_id should be 123" do
      expect(@notification.transaction_id).to eq "123"
    end

    it "gross should not be in cents 33 " do
      expect(@notification.gross).to eq "33"
    end

    it "currency should be EUR" do
      expect(@notification.currency).to eq "EUR"
    end

    it "received_at should be 26.11.2007" do
      expect(@notification.received_at.strftime("%d.%m.%Y")).to eq '26.11.2007'
    end

    it "should be a test notification" do
      expect(@notification.test?).to eq true
    end
  end

end
