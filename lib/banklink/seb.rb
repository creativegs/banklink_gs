module Banklink
  module Seb
    # mattr_accessor :service_url
    self.service_url
      if SebLV.service_url.present?
        return SebLV.service_url
      else
        return SebLT.service_url
      end
    end
  end
end