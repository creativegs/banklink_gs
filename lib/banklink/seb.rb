module Banklink
  module Seb
    def self.service_url
      if SebLT.service_url.nil?
        return SebLV.service_url
      else
        return SebLT.service_url
      end
    end
  end
end