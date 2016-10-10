module Banklink
  module Swedbank14

    # Raw X509 certificate of the bank, string format.
    mattr_accessor :bank_cert
    # RSA public key of the bank, taken from the X509 certificate of the bank. OpenSSL container.
    def self.get_bank_cert
      cert = self.bank_cert
      raise ArgumentError.new("No :bank_cert loaded for #{self.name}") if cert.blank?
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
      #   order_id: "1234567",
      #   payment_id: "666999"
      #   amount: "1.99",
      #   message: "Thanks for your purchase, your unique order number is 1234567",
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
        @fields["VK_STAMP"] = options[:order_id] #, 20, Query ID
        @fields["VK_AMOUNT"] = options[:amount]# , 12, Amount payable
        @fields["VK_CURR"] = "EUR" # , 3, Name of the currency: EUR
        @fields["VK_REF"] = get_valid_vk_ref(options[:payment_id].to_s) # , 35, Payment order reference number
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

      def get_valid_vk_ref(payment_id)
        payment_id_array = payment_id.split('').map(&:to_i)
        seventhreeeone_array = [7,3,1]
        seventhreeeone_array_index = 0

        payment_id_size = payment_id_array.length
        multiply_array = Array.new(payment_id_size)
        multiply_array_index = multiply_array.length - 1

        result = 0

        # Gets multiplication array with 731
        while multiply_array_index > -1
          multiply_array[multiply_array_index] = seventhreeeone_array[seventhreeeone_array_index]
          seventhreeeone_array_index += 1
          if seventhreeeone_array_index > 2
            seventhreeeone_array_index = 0
          end
          multiply_array_index -= 1
        end

        # Get endcoding sum
        payment_id_array.each_with_index do |payment_id, index|
           result += payment_id_array[index] * multiply_array[index]
        end

        # How near is it to next digit with 0
        big_digit = 10
        last_result_digit = result % 10

        if last_result_digit == 0
          big_digit = 0
        else
          big_digit -= last_result_digit
        end

        payment_id += big_digit.to_s

        return payment_id
      end

      def hasheable_fields
        return @fields
      end

      def form_fields
        return @form_fields ||= @fields.merge(mac_hash).merge(@settings)
      end

      private
        def ensure_needed_fields!
          raise ArgumentError.new("At least one mandatory field is not filled! Make sure all of :merchant_id, :order_id, :payment_id, :message, :success_url and :fail_url are provided!") unless all_fields_filled?
        end

        def all_fields_filled?
          return hasheable_fields.select{|k, v| v.nil?}.none?
        end

        def mac_hash
          return {"VK_MAC" => generate_v14_mac(hasheable_fields)}
        end
    end

    class Response
      include V14Mac

      def initialize(params={})
        # VK_SERVICE,4,Service number (1111)
        # VK_VERSION,3,Used encryption algorithm (008)
        # VK_SND_ID,15,ID of the author of the query (Bank’s ID)
        # VK_REC_ID,15,ID of the recipient of the query (Merchant’s ID)
        # VK_STAMP,20,Query ID

        # VK_T_NO,20,Payment order number ## only in :success
        # VK_AMOUNT,12,Amount paid ## only in :success
        # VK_CURR,3,Name of the currency: EUR ## only in :success
        # VK_REC_ACC,34,Recipient’s account number ## only in :success
        # VK_REC_NAME,70,Recipient’s name ## only in :success
        # VK_SND_ACC,34,Remitter’s account number ## only in :success
        # VK_SND_NAME,70,Remitter’s name ## only in :success

        # VK_REF,35,Payment order reference number
        # VK_MSG,95,Description of payment order
        # VK_T_DATETIME,24,Payment order date and time in DATETIME format ## only in :success
        # -
        # VK_MAC,700,Control code / signature
        # VK_ENCODING,12,Message encoding. UTF-8 (by default), ISO-8859-1 or WINDOWS-1257
        # VK_LANG,3,Preferable language of communication (EST, ENG or RUS)
        # VK_AUTO,1,N=reply by moving the customer to the merchant’s page.

        @params = params
      end

      def hasheable_fields
        return params.slice("VK_SERVICE", "VK_VERSION", "VK_SND_ID", "VK_REC_ID", "VK_STAMP", "VK_T_NO", "VK_AMOUNT", "VK_CURR", "VK_REC_ACC", "VK_REC_NAME", "VK_SND_ACC", "VK_SND_NAME", "VK_REF", "VK_MSG", "VK_T_DATETIME")
      end

      def bank_signable_row
        return generate_hasheable_row(hasheable_fields)
      end

      def bank_signature_valid?
        return true if failed? # quickreturn true, no need to verify a failed response

        bank_cert = Banklink::Swedbank14.get_bank_cert

        return bank_cert.verify(OpenSSL::Digest::SHA1.new, signature, bank_signable_row)
      end

      def complete?
        params['VK_SERVICE'].to_s[/^11\d\d/].present?
      end

      def failed?
        params['VK_SERVICE'].to_s[/19\d\d/].present?
      end

      def status
        stat = if complete?
          'Completed'
        else
          'Failed'
        end

        return stat
      end

      # The order id we passed to the form helper.
      def item_id
        params['VK_STAMP']
      end

      def transaction_id
        params['VK_REF'][0..-2] # return all but the last digit
      end

      def params
        return @params
      end

      def merchant_id
        return params["VK_REC_ID"]
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
        # require 'date'
        date = params['VK_T_DATETIME']
        return nil if date.blank?
        return date.to_datetime.to_date
      end

      def redirect?
        return params["VK_AUTO"].to_s[/\AN\z/].present?
      end

      def signature
        Base64.decode64(params['VK_MAC'])
      end

      # The money amount we received, string.
      def gross
        params['VK_AMOUNT']
      end

      # If our request was sent automatically by the bank (true) or manually
      # by the user triggering the callback by pressing a "return" button (false).
      def automatic?
        return !redirect?
      end

    end

  end
end
