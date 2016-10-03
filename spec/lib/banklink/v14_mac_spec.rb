# rspec spec/lib/banklink/v14_mac_spec.rb
RSpec.describe V14Mac do
  # implicitly included in Banklink::Swedbank14::Helper
  klass = Banklink::Swedbank14::Helper
  let(:subject) { klass.new(valid_swed_14_options) }
  let(:swed14_helper) { Banklink::Swedbank14::Helper.new(valid_swed_14_options) }
  let(:swed14_no_message_helper) { Banklink::Swedbank14::Helper.new(valid_swed_14_options_no_message) }

  describe "#func_p(val)" do
    it "should return the length of string formatted with leading zeroes" do
      expect(subject.func_p("abc")).to eq "003"
    end
  end

  describe "#generate_hasheable_row" do
    it "should expect an object that responds to .hasheable_fields and return their MAC008 string" do
      Timecop.freeze("2016-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR02014760807521234567890007Thanks!038https://testtest.ee/banklinkreturn.php038https://testtest.ee/banklinkcancel.php0242016-10-10T09:25:52+0300"
        expect(swed14_helper.generate_hasheable_row).to eq exp
      end
    end

    it "should return a correct row if message is empty" do
      Timecop.freeze("2014-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR02014129223521234567890000038https://testtest.ee/banklinkreturn.php038https://testtest.ee/banklinkcancel.php0242014-10-10T09:25:52+0300"
        expect(swed14_no_message_helper.generate_hasheable_row).to eq exp
      end
    end
  end

  describe "#generate_v14_mac" do
    it "should return a base 64 encoded string" do
      Banklink::Swedbank14.privkey = swedbank_privkey

      Timecop.freeze("2016-09-08 12:00".to_datetime) do
        expect(swed14_helper.generate_v14_mac).to eq "tQdr0aCxzTijUrK1blg7BIaP2XODrsgdAnrP7StVfRdskdKwYSsc0mc70bKQNZPPuk2bhdE6BO1by8N7wN7uCR18TaS6orMXphGzMpzTphFgPhb9RpPk0y/2oBN7MGY5legADgvg8qEAyJJWTU38P0ifI/n22F6v34iuY0af8t0="
      end

    end
  end

end
