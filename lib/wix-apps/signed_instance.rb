require 'base64'
require 'multi_json'
require 'openssl'

module Wix
  module Apps

    class SignedInstanceParseError < Exception
    end

    class SignedInstanceNoSecretKey < Exception
    end

    # This class deals with Wix Signed Instance
    # (http://dev.wix.com/docs/display/DRAF/Using+the+Signed+App+Instance)
    #
    # Example:
    # si = SignedInstance.new('vrinSv2HB9tqbnJ....')
    class SignedInstance

      # maps required instance properties to object attributes
      REQUIRED_PROPERTIES = {
          'instanceId' => :instance_id,
          'signDate' => :sign_date,
          'permissions' => :permissions,
          'ipAndPort' => :ip_and_port,
          'vendorProductId' => :vendor_product_id,
          'aid' => :aid,
          'siteOwnerId' => :site_owner_id,
      }

      # maps optional instance properties to object attributes
      OPTIONAL_PROPERTIES = {
          'uid' => :uid,
          'originInstanceId' => :origin_instance_id,
      }

      PERMISSIONS_OWNER = 'OWNER'

      attr_reader :raw_signed_instance, :strict_properties
      attr_reader *(REQUIRED_PROPERTIES.values + OPTIONAL_PROPERTIES.values)

      # @param [String] raw_signed_instance The "instance" parameter Wix sends with the request
      # @param [Hash] options Options for
      def initialize(raw_signed_instance, options={})
        self.strict_properties = options[:strict_properties].nil? ? true : !!options[:strict_properties]
        self.secret_key = options[:secret_key] || options[:secret] # :secret for backwards compatibility
        raise SignedInstanceNoSecretKey.new('secret key must be provided') if secret_key.nil?
        self.raw_signed_instance = raw_signed_instance
        raise SignedInstanceParseError.new('invalid instance signature') unless instance_signature_valid?

        initialize_from_signed_instance
      end

      # owner or site collaborator visiting?
      def owner_permissions?
        permissions == PERMISSIONS_OWNER
      end

      # did the one single site owner log in?
      def owner_logged_in?
        # note: site owner id is required so we wouldn't have to check for nil,
        # but this method's output can be very important and I'm paranoid. ;)
        !site_owner_id.nil? && site_owner_id == uid
      end

      private

      attr_accessor :secret_key
      attr_writer :raw_signed_instance, :strict_properties
      attr_writer *(REQUIRED_PROPERTIES.values + OPTIONAL_PROPERTIES.values)

      # validates signature
      def instance_signature_valid?
        signature, encoded_json = (raw_signed_instance || '').split('.', 2)
        return false if signature.nil? || encoded_json.nil?

        digest = OpenSSL::Digest.new('sha256')
        hmac_digest = OpenSSL::HMAC.digest(digest, secret_key, encoded_json)
        my_signature = Base64.urlsafe_encode64(hmac_digest).gsub('=', '')

        my_signature == signature
      end

      # initializes object attributes from parsed instance
      def initialize_from_signed_instance
        encoded_json = raw_signed_instance.split('.', 2).last

        # Need to add Base64 padding.
        # (http://stackoverflow.com/questions/4987772/decoding-facebooks-signed-request-in-ruby-sinatra)
        padded_json = encoded_json
        padded_json += ('=' * (4 - encoded_json.length % 4)) if padded_json.length % 4 != 0

        begin
          json = Base64.urlsafe_decode64(padded_json)
          signed_instance = MultiJson.load(json)
        rescue ArgumentError, MultiJson::ParseError => e
          raise SignedInstanceParseError.new(e.message)
        end

        # set all required instance properties
        REQUIRED_PROPERTIES.each { |instance_key, attribute|
          instance_value = signed_instance[instance_key]
          raise SignedInstanceParseError.new("missing instance property: #{instance_key}") if strict_properties && instance_value.nil?
          send "#{attribute}=", instance_value
        }
        # overwrite sign date with real DateTime object
        self.sign_date = DateTime.parse(sign_date)

        # set all optional instance properties (if set)
        OPTIONAL_PROPERTIES.each { |instance_key, attribute|
          send "#{attribute}=", signed_instance[instance_key] if signed_instance.has_key? instance_key
        }
      end
    end
  end
end
