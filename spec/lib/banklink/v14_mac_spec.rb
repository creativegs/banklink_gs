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

  describe "#generate_hasheable_row(hasheable_fields)" do
    it "should expect an object that responds to .hasheable_fields and return their MAC008 string" do
      Timecop.freeze("2016-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR0076669995007Thanks!038https://testtest.ee/banklinkreturn.php038https://testtest.ee/banklinkcancel.php0242016-10-10T09:25:52+0300"
        expect(swed14_helper.generate_hasheable_row(swed14_helper.hasheable_fields)).to eq exp
      end
    end

    it "should return a correct row if message is empty" do
      Timecop.freeze("2014-10-10T09:25:52+0300".to_datetime) do
        exp = "0041012003008006TRADER01012345678900041.99003EUR0076669995000038https://testtest.ee/banklinkreturn.php038https://testtest.ee/banklinkcancel.php0242014-10-10T09:25:52+0300"
        expect(swed14_no_message_helper.generate_hasheable_row(swed14_no_message_helper.hasheable_fields)).to eq exp
      end
    end
  end

  describe "#generate_v14_mac(hasheable_fields)" do
    it "should return a base64 encoded string" do
      Banklink::Swedbank14.privkey = swedbank_privkey

      Timecop.freeze("2016-09-08 12:00".to_datetime) do
        expect(swed14_helper.generate_v14_mac(swed14_helper.hasheable_fields)).to eq "RbiJFYMZ/ZxJxi30j3Orb3x4e8ZqX0mAOwW4ZAm94ViY8sTgRu0Klw81wl9rE1RXbtlwcsyapPfu2r+GdUVoHArHeePXdB5UIgFsv9UsPJqvkE0TAhhVkh96ZkoNSG5O+HuylbELhGTNgnI5LS3tB8MYusoPskxGmQQg+KqaSHc="
      end

    end
  end

end
