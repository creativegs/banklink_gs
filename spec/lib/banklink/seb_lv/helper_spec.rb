# rspec spec/lib/banklink/seb_lv/helper_spec.rb
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

  describe "#redirect_url" do
    it "should work without errors" do
      expect{@helper.redirect_url}.to_not raise_error
    end
  end

end
