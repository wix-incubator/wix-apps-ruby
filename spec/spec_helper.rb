require 'bundler/setup'
require 'json'
Bundler.require(:default, :development)

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}

require 'rack/test'

def encode_base64(payload)
  Base64.urlsafe_encode64(payload).gsub('=', '')
end

def decode_base64(encoded_payload)
  padded = encoded_payload
  padded += ('=' * (4 - encoded_payload.length % 4)) if padded.length % 4 != 0

  Base64.urlsafe_decode64(padded)
end

def decode(signed_instance)
  signature, encoded_json = signed_instance.split('.', 2)
  decode_base64(encoded_json)
end

def sign(payload)
  sign_string JSON.dump(payload)
end

def sign_string(payload)
  encoded_payload = encode_base64(payload)
  digest = OpenSSL::Digest.new('sha256')
  hmac_digest = OpenSSL::HMAC.digest(digest, SECRET_KEY, encoded_payload)
  my_signature = Base64.urlsafe_encode64(hmac_digest).gsub('=', '')
  "#{my_signature}.#{encoded_payload}"
end

def params_required
  {
    instanceId: '9f9c5c16-59c8-4708-8c25-855505daa954',
    signDate: DateTime.now.rfc3339,
    permissions: '',
    ipAndPort: '123.123.123.123:1234',
    vendorProductId: '',
    aid: '12645948-59c8-4708-8c25-855505dac8ca',
    siteOwnerId: '92771668-366f-4ec6-be21-b32c78e7b734'
  }
end
