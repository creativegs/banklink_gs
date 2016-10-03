#require 'banklink/swedbank14/helper'
#require 'banklink/swedbank14/response'

module Banklink
  module Swedbank14

    # Raw X509 certificate of the bank, string format.
    mattr_accessor :bank_cert
    # RSA public key of the bank, taken from the X509 certificate of the bank. OpenSSL container.
    def self.get_bank_cert
      cert = self.bank_cert
      OpenSSL::X509::Certificate.new(cert.gsub(/\s{2,}/, '')).public_key
    end

    mattr_accessor :privkey
    # Our RSA private key. OpenSSL container.
    def self.get_privkey
      private_key = self.privkey
      raise ArgumentError.new("No :privkey loaded for #{self.name}") if private_key.blank?
      OpenSSL::PKey::RSA.new(private_key.gsub(/\s{2,}/, ''))
    end

    class Helper
      include V14Mac

      # Expected options are:
      #   options = {
      #   merchant_id: "STOCK", # or "SWISSLAN"
      #   payment_id: "1234567",
      #   amount: "1.99",
      #   message: "Thenks for your purchase, your unique order number is 1234567",
      #   success_url: "https://domain.com/success/path",
      #   fail_url: "https://domain.com/fail/path",
      # }
      def initialize(options={})
        # Field, length, description
        # "VK_SERVICE", 4, Service number (1012)
        # "VK_VERSION", 3, Used encryption algorithm (008)
        # "VK_SND_ID", 15, ID of the author of the query (Merchant’s ID)
        # "VK_STAMP", 20, Query ID
        # "VK_AMOUNT", 12, Amount payable
        # "VK_CURR", 3, Name of the currency: EUR
        # "VK_REF", 35, Payment order reference number
        # "VK_MSG", 95, Description of payment order
        # "VK_RETURN", 255, URL where reply of successful transaction is sent
        # "VK_CANCEL", 255, URL where reply of failed transaction is sent
        # VK_DATETIME, 24, Date and time of the initiation of the query in DATETIME format (ISO)

        #== Non-encodeable fields==
        # "VK_MAC", 700, Control code / signature
        # "VK_ENCODING", 12 Message encoding. UTF-8 (by default), ISO-8859-1 or WINDOWS-1257
        # "VK_LANG", 3, Preferable language of communication (EST, ENG or RUS)

        @fields = {}

        @fields["VK_SERVICE"] = "1012"
        @fields["VK_VERSION"] = "008"
        @fields["VK_SND_ID"] = options[:merchant_id] # , 15, ID of the author of the query (Merchant’s ID)
        @fields["VK_STAMP"] = options[:payment_id] #, 20, Query ID
        @fields["VK_AMOUNT"] = options[:amount]# , 12, Amount payable
        @fields["VK_CURR"] = "EUR" # , 3, Name of the currency: EUR
        @fields["VK_REF"] = "#{Time.zone.now.to_i}#{options[:payment_id]}" # , 35, Payment order reference number
        @fields["VK_MSG"] = options[:message].to_s #, 95, Description of payment order
        @fields["VK_RETURN"] = options[:success_url]# , 255, URL where reply of successful transaction is sent
        @fields["VK_CANCEL"] = options[:fail_url] # , 255, URL where reply of failed transaction is sent
        @fields["VK_DATETIME"] = Time.zone.now.strftime("%FT%T%z")  #=> "2016-10-03T20:11:18+0300" #  , 24, Date and time of the initiation of the query in DATETIME format (ISO)

        # "VK_MAC", 700, Control code / signature
        @settings = {}
        @settings["VK_ENCODING"] = "UTF-8" #, 12 Message encoding. UTF-8 (by default), ISO-8859-1 or WINDOWS-1257
        @settings["VK_LANG"] = "EST" #, 3, Preferable language of communication (EST, ENG or RUS)

        ensure_needed_fields!
      end

      def service_url
        return "https://www.swedbank.ee/banklink"
      end

      def hasheable_fields
        return @fields
      end

      def form_fields
        return @form_fields ||= @fields.merge(mac_hash).merge(@settings)
      end

      private
        def ensure_needed_fields!
          raise ArgumentError.new("At least one mandatory field is not filled! Make sure all of :merchant_id, :order_id, :message, :success_url and :fail_url are provided!") unless all_fields_filled?
        end

        def all_fields_filled?
          return hasheable_fields.select{|k, v| v.nil?}.none?
        end

        def mac_hash
          return {"VK_MAC" => generate_v14_mac}
        end
    end

    class Response
      # include Banklink::Common

      attr_accessor :params
      attr_accessor :raw

      # set this to an array in the subclass, to specify which IPs are allowed to send requests
      attr_accessor :production_ips

      def initialize(post, options = {})
        @options = options
        empty!
        parse(post)
      end

      def gross_cents
        (gross.to_f * 100.0).round
      end

      # This combines the gross and currency and returns a proper Money object.
      # this requires the money library located at http://dist.leetsoft.com/api/money
      def amount
        return gross_cents
      end

      # reset the notification.
      def empty!
        @params  = Hash.new
        @raw     = ""
      end

      # Check if the request comes from an official IP
      def valid_sender?(ip)
        return true if Rails.env == :test || production_ips.blank?
        production_ips.include?(ip)
      end

          # A helper method to parse the raw post of the request & return
      # the right Notification subclass based on the sender id.
      #def self.get_notification(http_raw_data)
      #  params = ActiveMerchant::Billing::Integrations::Notification.new(http_raw_data).params
      #  Banklink.get_class(params)::Notification.new(http_raw_data)
      #end

      def get_data_string
        generate_data_string(params['VK_SERVICE'], params, Swedbank.required_service_params)
      end

      def bank_signature_valid?(bank_signature, service_msg_number, sigparams)
        Swedbank.get_bank_public_key.verify(OpenSSL::Digest::SHA1.new, bank_signature, generate_data_string(service_msg_number, sigparams, Swedbank.required_service_params))
      end

      def complete?
        params['VK_SERVICE'] == '1101'
      end

      def waiting?
        params['VK_SERVICE'] == '1201'
      end

      def failed?
        params['VK_SERVICE'] == '1901'
      end

      def currency
        params['VK_CURR']
      end

      # The order id we passed to the form helper.
      def item_id
        params['VK_STAMP']
      end

      def transaction_id
        params['VK_REF']
      end

      def sender_name
        params['VK_SND_NAME']
      end

      def sender_bank_account
        params['VK_SND_ACC']
      end

      def reciever_name
        params['VK_REC_NAME']
      end

      def reciever_bank_account
        params['VK_REC_ACC']
      end

      # When was this payment received by the client.
      # We're expecting a dd.mm.yyyy format.
      def received_at
        require 'date'
        date = params['VK_T_DATE']
        return nil unless date
        day, month, year = *date.split('.').map(&:to_i)
        Date.civil(year, month, day)
      end

      def signature
        Base64.decode64(params['VK_MAC'])
      end

      # The money amount we received, string.
      def gross
        params['VK_AMOUNT']
      end

      # Was this a test transaction?
      def test?
        params['VK_REC_ID'] == 'testvpos'
      end

      # TODO what should be here?
      def status
        if complete?
          return 'Completed'
        elsif waiting?
          return "Waiting"
        end

        return 'Failed'
      end

      # If our request was sent automatically by the bank (true) or manually
      # by the user triggering the callback by pressing a "return" button (false).
      def automatic?
        params['VK_AUTO'].upcase == 'Y'
      end

      def success?
        acknowledge && complete?
      end

      # We don't actually acknowledge the notification by making another request ourself,
      # instead, we check the notification by checking the signature that came with the notification.
      # This method has to be called when handling the notification & deciding whether to process the order.
      # Example:
      #
      #   def notify
      #     notify = Notification.new(params)
      #
      #     if notify.acknowledge
      #       ... process order ... if notify.complete?
      #     else
      #       ... log possible hacking attempt ...
      #     end
      def acknowledge
        bank_signature_valid?(signature, params['VK_SERVICE'], params)
      end

    end

  end
end
