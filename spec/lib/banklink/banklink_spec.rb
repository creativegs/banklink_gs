# rspec spec/lib/banklink/banklink_spec.rb
RSpec.describe Banklink::Common do
  class TestSwed
    include Banklink::Common
  end

  let(:swed_helper) { TestSwed.new }

  describe "#func_p" do
    it "func_p should return length of a string in correct format" do
      expect(swed_helper.func_p("ĀĒŪĪĻĶŠ")).to eq "007"
    end
  end

  describe "#generate_data_string" do
    it "should generate data string correctly" do
      expect(swed_helper.generate_data_string(1002, PARAMS_1002, Banklink::Swedbank.required_service_params)).to eq "003foo003bar003goo006tooboo00510565003LVL003dsa005Āžēīū"
    end
  end

end
