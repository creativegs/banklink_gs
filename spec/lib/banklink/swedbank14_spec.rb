# rspec spec/lib/banklink/swedbank14_spec.rb
RSpec.describe Banklink::Swedbank14 do

  describe ".get_bank_cert" do
    xit "should return a string (public key)" do
      expect(0).to eq 1
    end
  end

  describe ".get_privkey" do
    it "should return a privkey object (not a string)" do
      Banklink::Swedbank14.privkey = swedbank_privkey
      expect(Banklink::Swedbank14.get_privkey.class).to eq OpenSSL::PKey::RSA
    end

    it "should raise an argument error if no privkey string loaded" do
      Banklink::Swedbank14.privkey = nil
      expect{Banklink::Swedbank14.get_privkey}.to raise_error(ArgumentError, /^No :privkey loaded/)
    end
  end

  describe "Helper" do
    klass = Banklink::Swedbank14::Helper
    let(:valid_options) { valid_swed_14_options }
    let(:invalid_options) { Hash.new }
    let(:valid_helper) { klass.new(valid_swed_14_options) }

    describe "#initialize" do
      it "should return a helper instance" do
        Timecop.freeze("2016-09-08 12:00".to_datetime) do
          expect(klass.new(valid_options).class).to eq(klass)
        end
      end

      it "should raise an ArgumentError if not all required options given" do
        Timecop.freeze("2016-09-08 12:00".to_datetime) do
          expect{klass.new(invalid_options)}.to raise_error(ArgumentError, /^At least one mandatory field is not filled!/)
        end
      end
    end

    describe "#get_valid_vk_ref(payment_id)" do
      it "should return a 7-3-1 coded integer" do
        expect(valid_helper.get_valid_vk_ref("666999")).to eq "6669995"
      end
    end

    describe "#form_fields" do
      it "should return a Hash with correct data" do
        exp = {
          "VK_SERVICE" => "1012",
          "VK_VERSION" => "008",
          "VK_SND_ID" => "TRADER",
          "VK_STAMP" => "1234567890",
          "VK_AMOUNT" => "1.99",
          "VK_CURR" => "EUR",
          "VK_REF" => "6669995",
          "VK_MSG" => "Thanks!",
          "VK_RETURN" => "https://testtest.ee/banklinkreturn.php",
          "VK_CANCEL" => "https://testtest.ee/banklinkcancel.php",
          "VK_DATETIME" => "2014-10-10T09:25:52+0300",
          "VK_MAC" => "TODO",
          "VK_ENCODING" => "UTF-8",
          "VK_LANG" => "EST"
        }

        Timecop.freeze("2014-10-10T09:25:52+0300".to_datetime) do
          allow_any_instance_of(valid_helper.class).to receive(:mac_hash).and_return({"VK_MAC" => "TODO"})

          expect(valid_helper.form_fields).to eq exp
        end
      end
    end
  end

  describe "Response" do
    let(:completed) { Banklink::Swedbank14::Response.new(swed_14_completed_response) }
    let(:failed) { Banklink::Swedbank14::Response.new(swed_14_failed_response) }
    let(:valid) { Banklink::Swedbank14::Response.new(swed_14_valid_response) }
    let(:invalid) { Banklink::Swedbank14::Response.new(swed_14_invalid_response) }

    describe "#initialize" do
      it "should make a response object for a failed payment" do
        expect(failed.class).to eq Banklink::Swedbank14::Response
      end

      it "should make a response object for a successful payment" do
        expect(completed.class).to eq Banklink::Swedbank14::Response
      end
    end

    describe "#hasheable_fields" do
      it "should return a hash with 15 keys" do
        expect(valid.hasheable_fields.keys.size).to eq 15
      end
    end

    describe "#bank_signable_row" do
      it "should return a specific string" do
        expect(valid.bank_signable_row).to eq valid_response_signable_row
      end
    end

    describe "#bank_signature_valid?" do
      it "should quickreturn true for a failed response without actual processing" do
        expect(failed.bank_signature_valid?).to eq true
      end

      it "should return true for a valid response with untampered MAC" do
        Banklink::Swedbank14.bank_cert = swed_bank_cert
        valid = Banklink::Swedbank14::Response.new(swed_14_valid_response)
        expect(valid.bank_signature_valid?).to eq true
      end

      it "should return false for a valid response with MAC that has been tampered with" do
        invalid = Banklink::Swedbank14::Response.new(swed_14_invalid_response)
        expect(invalid.bank_signature_valid?).to eq false
      end
    end

    describe "#complete?" do
      it "should return true for a complete response" do
        expect(completed.complete?).to eq true
      end

      it "should return false for a failed response" do
        expect(failed.complete?).to eq false
      end
    end

    describe "#status" do
      it "should return 'Completed' for a complete response" do
        expect(completed.status).to eq 'Completed'
      end

      it "should return 'Failed' for a fail response" do
        expect(failed.status).to eq 'Failed'
      end
    end

    describe "#item_id" do
      it "should return the 'VK_REF' field contents sans the last control digit (producing app-side transaction_id)" do
        expect(completed.item_id).to eq "1234567890"
      end
    end

    describe "#transaction_id" do
      it "should return the loggable and originating transaction id" do
        expect(completed.transaction_id).to eq "666999"
      end
    end

    describe "#params" do
      it "should return the originating params hash" do
        expect(completed.params).to eq swed_14_completed_response
      end
    end

    describe "#received_at" do
      it "should return a date string" do
        expect(completed.received_at.to_s).to eq("2014-10-10")
      end
    end

    describe "#redirect?" do
      it "should return true if VK_AUTO if false" do
        redirectable = Banklink::Swedbank14::Response.new(swed_14_completed_response.merge("VK_AUTO" => "N"))
        expect(redirectable.redirect?).to eq true
      end

      it "should return false if VK_AUTO if true" do
        no_redirect = Banklink::Swedbank14::Response.new(swed_14_completed_response.merge("VK_AUTO" => "Y"))
        expect(no_redirect.redirect?).to eq false
      end
    end

    describe "#signature" do
      it "should return a base64 encoded string" do
        expect(valid.signature.size).to eq 128
      end
    end

    describe "#automatic?" do
      it "should return true if VK_AUTO was Y" do
        no_redirect = Banklink::Swedbank14::Response.new(swed_14_completed_response.merge("VK_AUTO" => "Y"))
        expect(no_redirect.automatic?).to eq true
      end
    end


  end

end
