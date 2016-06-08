require 'spec_helper'

RSpec.describe Banklink::SebLV::Helper do
  before :all do
    options = {}
    options[:amount] = '1.55'
    options[:currency] = 'LVL'
    options[:return] = 'http://default/'
    options[:reference] = '54'
    options[:message] = 'Pay for smtx'

    @helper = Banklink::SebLV::Helper.new(300, '300', options)
  end

  it "should have created 12 form fields" do
    expect(@helper.form_fields.size).to eq 11
  end

end
