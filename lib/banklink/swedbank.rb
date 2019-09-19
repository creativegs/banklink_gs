require 'banklink/swedbank/helper'
require 'banklink/swedbank/notification'

module Banklink
  module Swedbank

    # Raw X509 certificate of the bank, string format.
    mattr_accessor :bank_certificate

    # RSA public key of the bank, taken from the X509 certificate of the bank. OpenSSL container.
    def self.get_bank_public_key
      cert = self.bank_certificate
      OpenSSL::X509::Certificate.new(cert.gsub(/  /, '')).public_key
    end

    mattr_accessor :private_key
    mattr_accessor :pem_pass

    # Our RSA private key. OpenSSL container.
    def self.get_private_key
      private_key = self.private_key
      pem_pass = self.pem_pass
      OpenSSL::PKey::RSA.new(private_key.gsub(/  /, ''), pem_pass)
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
    1001 => [
      'VK_SERVICE',
      'VK_VERSION',
      'VK_SND_ID',
      'VK_STAMP',
      'VK_AMOUNT',
      'VK_CURR',
      'VK_ACC',
      'VK_NAME',
      'VK_REF',
      'VK_MSG'],
    1002 => [
      'VK_SERVICE',
      'VK_VERSION',
      'VK_SND_ID',
      'VK_STAMP',
      'VK_AMOUNT',
      'VK_CURR',
      'VK_REF',
      'VK_MSG' ],
    1101 => [
      'VK_SERVICE',
      'VK_VERSION',
      'VK_SND_ID',
      'VK_REC_ID',
      'VK_STAMP',
      'VK_T_NO',
      'VK_AMOUNT',
      'VK_CURR',
      'VK_REC_ACC',
      'VK_REC_NAME',
      'VK_SND_ACC',
      'VK_SND_NAME',
      'VK_REF',
      'VK_MSG',
      'VK_T_DATE'],
    1201 => [
      'VK_SERVICE',
      'VK_VERSION',
      'VK_SND_ID',
      'VK_REC_ID',
      'VK_STAMP',
      'VK_AMOUNT',
      'VK_CURR',
      'VK_REC_ACC',
      'VK_REC_NAME',
      'VK_SND_ACC',
      'VK_SND_NAME',
      'VK_REF',
      'VK_MSG'],
    1901 => [
      'VK_SERVICE',
      'VK_VERSION',
      'VK_SND_ID',
      'VK_REC_ID',
      'VK_STAMP',
      'VK_REF',
      'VK_MSG']
    }

  end
end
