require 'spec_helper'
include Banklink::Common

RSpec.describe Banklink::Common do

  it "func_p should return length of a string in correct format" do
    expect(func_p("ĀĒŪĪĻĶŠ")).to eq "007"
  end

  it "should generate data string correctly" do
    expect(generate_data_string(1002, PARAMS_1002, Banklink::Swedbank.required_service_params)).to eq "003foo003bar003goo006tooboo00510565003LVL003dsa005Āžēīū"
  end

end
