module Banklink #:nodoc:
  module SebLT
    class Helper
      attr_reader :fields
      include Banklink::Common

      def initialize(transaction, account, options = {})

        @options = options
        @fields = {}

        @options['VK_SND_ID']  = account
        @options['VK_STAMP']   = transaction
        @options['VK_AMOUNT']  = options[:amount]
        @options['VK_CURR']    = options[:currency] || "EUR"
        @options['VK_ACC']     = options[:acc]
        @options['VK_NAME']    = options[:name] || "Company"
        @options['VK_REF']     = transaction
        @options['VK_MSG']     = options[:message]
        @options['VK_LANG']    = options[:lang] if options[:lang]
        @options['VK_RETURN']  = options[:return]

        if options[:service_msg_number]
          @service_msg_number = options.delete(:service_msg_number)
        else
          @service_msg_number = default_service_msg_number
        end

        add_required_params
        add_vk_crc

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

      def add_vk_crc
        # Signature used to validate previous parameters
        add_field('VK_MAC', generate_mac(@service_msg_number, form_fields, SebLT.required_service_params))
      end

      def add_return_url_field
        add_field('VK_RETURN', @options['VK_RETURN'])
      end

      def add_lang_field
        if @options['VK_LANG']
          add_field(vk_lang_param, @options['VK_LANG'])
        else
          add_field vk_lang_param, vk_lang
        end
      end

      def add_required_params
        required_params = SebLT.required_service_params[@service_msg_number]
        required_params.each do |param|
          param_value = (@options.delete(param) || send(param.to_s.downcase)).to_s
          add_field param, encode_to_utf8(param_value)
        end
      end

      def vk_lang
        'LIT'
      end

      def vk_lang_param
        'VK_LANG'
      end

      def vk_service
        @service_msg_number
      end

      def vk_version
        '001'
      end

      def redirect_url
        SebLT.service_url
      end

      def default_service_msg_number
        "1001"
      end

    end
  end
end
