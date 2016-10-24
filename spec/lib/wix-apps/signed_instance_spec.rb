require 'spec_helper'

describe 'signing test method' do

  let(:raw_signed_instance) { 'naQKltLRVJwLVN90qQYpmmyzkVqFIH0hpvETYuivA1U.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDE5OjQ3OjMxLjYyNFoiLCJ1aWQiOm51bGwsInBlcm1pc3Npb25zIjpudWxsfQ' }
  let(:raw_signed_instance_with_user_id) { 'K78r2uwAQbvA68u-bXxn2cdIUFMZIp8v9XfA_hd-iyo.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDIyOjEwOjU2Ljg3NVoiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6bnVsbH0' }
  let(:raw_signed_in_owner_mode) { 'AjQ3BniGXfSOjKw4ej_V0kh4-WF5eB2IRnbvsak9kwc.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDIyOjEyOjE2LjU4OVoiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6Ik9XTkVSIn0' }

  it 'encodes correctly 1/3' do
    decoded_json = decode(raw_signed_instance)
    expect(sign_string(decoded_json)).to eq raw_signed_instance
  end

  it 'encodes correctly 2/3' do
    decoded_json = decode(raw_signed_instance_with_user_id)
    expect(sign_string(decoded_json)).to eq raw_signed_instance_with_user_id
  end

  it 'encodes correctly 3/3' do
    decoded_json = decode(raw_signed_in_owner_mode)
    expect(sign_string(decoded_json)).to eq raw_signed_in_owner_mode
  end

end

describe Wix::Apps::SignedInstance do

  let(:params_with_user) {
    params_required.merge(uid: 'c713982b-9161-49bc-9ff5-67502e4b705b')
  }

  let(:params_with_owner) {
    params_required.merge(uid: '92771668-366f-4ec6-be21-b32c78e7b734', permissions: 'OWNER')
  }

  let(:invalid_raw_signed_instance) { 'Invalid signature format' }

  describe 'Initialization' do

    subject { Wix::Apps::SignedInstance.new(sign(params_required), secret_key: SECRET_KEY) }

    it 'parses instanceId' do
      expect(subject.instance_id).to eq params_required[:instanceId]
    end

    it 'parses sign_date as DateTime' do
      expect(subject.sign_date).to be_kind_of DateTime
    end

    it 'parses sign_date' do
      expect(subject.sign_date.rfc3339).to eq params_required[:signDate]
    end

    it 'returns nil as user id' do
      expect(subject.uid).to be_nil
    end

    it 'parses permissions' do
      expect(subject.permissions).to eq params_required[:permissions]
    end

    it 'parses ipAndPort' do
      expect(subject.ip_and_port).to eq params_required[:ipAndPort]
    end

    it 'parses vendorProductId' do
      expect(subject.vendor_product_id).to eq params_required[:vendorProductId]
    end

    it 'parses aid' do
      expect(subject.aid).to eq params_required[:aid]
    end

    it 'parses siteOwnerId' do
      expect(subject.site_owner_id).to eq params_required[:siteOwnerId]
    end

    it 'has owner not logged in' do
      expect(subject.owner_logged_in?).to eq false
    end

    describe 'With a user id' do
      subject { Wix::Apps::SignedInstance.new(sign(params_with_user), secret_key: SECRET_KEY) }

      it 'parses user id' do
        expect(subject.uid).to eq params_with_user[:uid]
      end

      it 'has owner not logged in' do
        expect(subject.owner_logged_in?).to eq false
      end

    end

    describe 'with an owner' do
      subject { Wix::Apps::SignedInstance.new(sign(params_with_owner), secret_key: SECRET_KEY) }

      it 'has owner logged in' do
        expect(subject.owner_logged_in?).to eq true
      end

      it 'parses permissions' do
        expect(subject.permissions).to eq 'OWNER'
      end

      it 'has owner permissions' do
        expect(subject.owner_permissions?).to eq true
      end
    end

    describe 'with missing required params' do

      params_required.keys.each do |key|
        params = params_required.reject { |k, _| k == key }
        subject { Wix::Apps::SignedInstance.new(sign(params), secret_key: SECRET_KEY) }
        it "raises an exception when #{key} is missing" do
          expect { subject }.to raise_error Wix::Apps::SignedInstanceParseError
        end
      end

    end
  end

  describe 'initialization without `strict_properties`' do
    let(:params) { {instanceId: '123456789'} }
    subject { Wix::Apps::SignedInstance.new(sign(params), secret_key: SECRET_KEY, strict_properties: false) }

    it 'has an instance_id' do
      expect(subject.instance_id).to eq params[:instanceId]
    end
  end

  describe 'signature validation' do

    describe 'with an invalid format' do
      subject { Wix::Apps::SignedInstance.new(invalid_raw_signed_instance, secret_key: SECRET_KEY) }

      it 'raise SignedInstance::ParseError' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceParseError
      end
    end

    describe 'without a secret' do
      subject { Wix::Apps::SignedInstance.new(sign(params_required)) }

      it 'raises SignedInstanceNoSecretKey' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceNoSecretKey
      end
    end

    describe 'with an incorrect secret' do
      subject { Wix::Apps::SignedInstance.new(sign(params_required), secret_key: 'another-secret') }

      it 'raise SignedInstanceParseError' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceParseError
      end
    end

    describe 'with a valid signature' do
      subject { Wix::Apps::SignedInstance.new(sign(params_required), secret_key: SECRET_KEY) }

      it 'should instantiate' do
        expect(subject).to be_instance_of Wix::Apps::SignedInstance
      end
    end

  end

end
