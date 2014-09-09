module Banklink #:nodoc:
  module SebLV
    class Helper
      attr_reader :fields
      include Banklink::Common

      def initialize(transaction, account, options = {})

        @options = options
        @fields = {}

        @options['IB_SND_ID'] = account
        @options['IB_PAYMENT_ID'] = transaction
        @options['IB_AMOUNT'] = options[:amount]
        @options['IB_CURR'] = options[:currency] || "EUR"
        @options['IB_FEEDBACK'] = options[:return]
        @options['IB_NAME'] = options[:name] || "Company"
        @options['IB_PAYMENT_DESC'] = options[:message]
        @options['IB_LANG'] = options[:lang] if options[:lang]

        if options[:service_msg_number]
          @service_msg_number = options.delete(:service_msg_number)
        else
          @service_msg_number = default_service_msg_number
        end

        add_required_params
        add_ib_crc

        add_lang_field
        add_return_url_field
      end


      def form_fields
        @fields
      end

      def self.mapping(attribute, options = {})
        self.mappings ||= {}
        self.mappings[attribute] = options
      end

      def add_field(name, value)
        return if name.blank? || value.blank?
        @fields[name.to_s] = value.to_s
      end

      def add_ib_crc
        # Signature used to validate previous parameters
        add_field('IB_CRC', generate_mac(@service_msg_number, form_fields, SebLV.required_service_params))
      end

      def add_return_url_field
        add_field('IB_FEEDBACK', @options['IB_FEEDBACK'])
      end

      def add_lang_field
        if @options['IB_LANG']
          add_field(ib_lang_param, @options['IB_LANG'])
        else
          add_field ib_lang_param, ib_lang
        end
      end

      def add_required_params
        required_params = SebLV.required_service_params[@service_msg_number]
        required_params.each do |param|
          param_value = (@options.delete(param) || send(param.to_s.downcase)).to_s
          add_field param, encode_to_utf8(param_value)
        end
      end

      def ib_lang
        'LAT'
      end

      def ib_lang_param
        'IB_LANG'
      end

      def ib_service
        @service_msg_number
      end

      def ib_version
        '001'
      end

      def redirect_url
        SebLV.service_url
      end

      # Default service message number.
      # Use '0002' because it requires the least amount of parameters.
      def default_service_msg_number
        "0002"
      end

    end
  end
end
