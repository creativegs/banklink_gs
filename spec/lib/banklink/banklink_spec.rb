# rspec spec/lib/banklink/banklink_spec.rb
RSpec.describe Banklink::Common do
  let(:swed14_helper) { Banklink::Swedbank14::Helper.new(valid_swed_14_options) }
  let(:swed14_no_message_helper) { Banklink::Swedbank14::Helper.new(valid_swed_14_options_no_message) }

  describe "#func_p" do
    it "func_p should return length of a string in correct format" do
      expect(swed14_helper.func_p("ĀĒŪĪĻĶŠ")).to eq "007"
    end
  end

  describe "#generate_data_string" do
    it "should generate data string correctly" do
      expect(swed14_helper.generate_data_string(1002, PARAMS_1002, Banklink::Swedbank.required_service_params)).to eq "003foo003bar003goo006tooboo00510565003LVL003dsa005Āžēīū"
    end
  end

  describe "#generate_hasheable_row" do
    it "should expect an object that responds to .hasheable_fields and return their MAC008 string" do
      Timecop.freeze("2016-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR003123007Thanks! 038http://testtest.ee/banklinkreturn.php038http://testtest.ee/banklinkcancel.php0242016-10-10T09:25:52+0300"
        expect(swed14_helper.generate_hasheable_row).to eq exp
      end
    end

    it "should return a correct row if message is empty" do
      Timecop.freeze("2014-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR003123000038http://testtest.ee/banklinkreturn.php038http://testtest.ee/banklinkcancel.php0242014-10-10T09:25:52+0300"
        expect(swed14_no_message_helper.generate_hasheable_row).to eq exp
      end
    end
  end

end
