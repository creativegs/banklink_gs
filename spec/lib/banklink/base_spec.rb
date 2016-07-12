# rspec spec/lib/banklink/base_spec.rb
RSpec.describe Hash do
  let(:hash) { Hash.new(a: :a, b: :b) }

  describe "#to_params" do
    it "should work without errors" do
      expect{hash.to_params}.to_not raise_error
    end
  end

end
