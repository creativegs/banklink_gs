require 'spec_helper'

RSpec.describe Banklink::SebLT::Helper do
  before :all do
    options = {}
    options[:amount] = '1.55'
    options[:currency] = 'LTL'
    options[:return] = 'http://default/'
    options[:reference] = '54'
    options[:message] = 'Pay for smtx'
    options[:acc] = 'LT417044060001223597'

    @helper = Banklink::SebLT::Helper.new(300, '300', options)
  end

  it "should have created 12 form fields" do
    expect(@helper.form_fields.size).to eq 13
  end

end
