require 'spec_helper'

RSpec.describe Banklink::Seb do

  context :service_url do

    it "should take first present value" do
      expect(Banklink::Seb.service_url).to eq "https://e.seb.lt/mainib/web.p"
    end

    it "seb lt should be nil" do
      expect(Banklink::SebLT.service_url).to eq nil

    end

  end


end
