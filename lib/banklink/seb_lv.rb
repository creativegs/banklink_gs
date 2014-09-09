require 'banklink/seb_lv/helper'
require 'banklink/seb_lv/notification'

module Banklink
  module SebLV

    # Raw X509 certificate of the bank, string format.
    mattr_accessor :bank_certificate
    # RSA public key of the bank, taken from the X509 certificate of the bank. OpenSSL container.
    def self.get_bank_public_key
      cert = self.bank_certificate
      # OpenSSL::X509::Certificate.new(cert.gsub(/  /, '')).public_key
      OpenSSL::X509::Certificate.new(cert).public_key
    end

    mattr_accessor :private_key
    # Our RSA private key. OpenSSL container.
    def self.get_private_key
      private_key = self.private_key
      OpenSSL::PKey::RSA.new(private_key.gsub(/  /, ''))
    end

    mattr_accessor :service_url

    def self.notification(post)
      Notification.new(post)
    end

    def self.helper(order, account, options = {})
      Helper.new(order, account, options)
    end

    # Define required fields for each service message.
    # We need to know this in order to calculate VK_MAC
    # from a given hash of parameters.
    # Order of the parameters is important.
    mattr_accessor :required_service_params
    self.required_service_params = {
    '0002' => [
      'IB_SND_ID',
      'IB_SERVICE',
      'IB_VERSION',
      'IB_AMOUNT',
      'IB_CURR',
      'IB_NAME',
      'IB_PAYMENT_ID',
      'IB_PAYMENT_DESC'
      ],
    '0003' => [
      'IB_SND_ID',
      'IB_SERVICE',
      'IB_VERSION',
      'IB_PAYMENT_ID',
      'IB_AMOUNT',
      'IB_CURR',
      'IB_REC_ID',
      'IB_REC_ACC',
      'IB_REC_NAME',
      'IB_PAYER_ACC',
      'IB_PAYER_NAME',
      'IB_PAYMENT_DESC',
      'IB_PAYMENT_DATE',
      'IB_PAYMENT_TIME'
      ],
    '0004' => [
      'IB_SND_ID',
      'IB_SERVICE',
      'IB_VERSION',
      'IB_REC_ID',
      'IB_PAYMENT_ID',
      'IB_PAYMENT_DESC',
      'IB_FROM_SERVER',
      'IB_STATUS'
      ]
    }

  end
end
