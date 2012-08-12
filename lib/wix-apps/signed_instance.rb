require 'base64'
require 'multi_json'
require 'openssl'

module Wix
  module Apps
    class SignedInstanceParseError < Exception;end
    class SignedInstanceNoSecretKey < Exception;end
    # This class deal with Wix Signed Instance
    # (http://dev.wix.com/display/wixdevelopersapi/The+Signed+Instance)
    #
    # Example:
    # si = SignedInstance.new('vrinSv2HB9tqbnJ....')
    class SignedInstance
      attr_reader :raw_signed_instance, :instance_id, :sign_date, :uid,
                  :permissions

      def initialize(raw_signed_instance, options = {})
        @raw_signed_instance = raw_signed_instance
        @secret = options[:secret]

        parse_signed_instance_data
      end

      # validates signature
      def valid?
        raise SignedInstanceNoSecretKey.new('Please provide secret key') if @secret.nil?
        digest  = OpenSSL::Digest::Digest.new('sha256')
        hmac_digest = OpenSSL::HMAC.digest(digest, @secret, @encoded_json)
        my_signature = Base64.urlsafe_encode64(hmac_digest).gsub('=','')

        return my_signature == @signature
      end

      #Owner mode on?
      def owner?
        permissions == 'OWNER'
      end

      private
      def parse_signed_instance_data
        @signature, @encoded_json = raw_signed_instance.split('.', 2)
        raise SignedInstanceParseError if @signature.nil? || @encoded_json.nil?

        # Need to add Base64 padding.
        # (http://stackoverflow.com/questions/4987772/decoding-facebooks-signed-request-in-ruby-sinatra)
        padded_json = @encoded_json + ('=' * (4 - @encoded_json.length % 4))

        begin
          @json = Base64.urlsafe_decode64(padded_json)
          signed_instance = MultiJson.load(@json)
        rescue ArgumentError, MultiJson::DecodeError => e
          raise SignedInstanceParseError.new(e.message)
        end

        @instance_id = signed_instance['instanceId']
        @sign_date = DateTime.parse(signed_instance['signDate'])
        raise SignedInstanceParseError if @instance_id.nil? || @sign_date.nil?

        @uid = signed_instance['uid']
        @permissions = signed_instance['permissions']
      end
    end
  end
end