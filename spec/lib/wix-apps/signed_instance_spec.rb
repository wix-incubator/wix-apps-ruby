require 'spec_helper'

describe Wix::Apps::SignedInstance do
  let(:raw_signed_instance) { 'naQKltLRVJwLVN90qQYpmmyzkVqFIH0hpvETYuivA1U.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDE5OjQ3OjMxLjYyNFoiLCJ1aWQiOm51bGwsInBlcm1pc3Npb25zIjpudWxsfQ' }
  let(:invalid_raw_signed_instance) { 'Incorect Raw Signed Instance' }
  let(:raw_signed_instance_with_user_id) { 'K78r2uwAQbvA68u-bXxn2cdIUFMZIp8v9XfA_hd-iyo.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDIyOjEwOjU2Ljg3NVoiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6bnVsbH0' }
  let(:raw_signed_in_owner_mode) { 'AjQ3BniGXfSOjKw4ej_V0kh4-WF5eB2IRnbvsak9kwc.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTA4VDIyOjEyOjE2LjU4OVoiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6Ik9XTkVSIn0' }

  subject { Wix::Apps::SignedInstance.new(raw_signed_instance, secret_key: SECRET_KEY) }

  describe 'Initialization' do
    describe 'invalid format' do
      subject { Wix::Apps::SignedInstance.new(invalid_raw_signed_instance, secret_key: SECRET_KEY) }

      it 'raise SignedInstance::ParseError' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceParseError
      end
    end

    it 'parse instance_id' do
      expect(subject.instance_id).to eq '9f9c5c16-59c8-4708-8c25-855505daa954'
    end

    it 'parse sign_date as DateTime' do
      expect(subject.sign_date).to be_kind_of DateTime
    end

    it 'parse sign_date' do
      expect(subject.sign_date).to eq DateTime.rfc3339('2012-08-08T19:47:31.624Z')
    end

    it 'return nil as user id' do
      expect(subject.uid).to be_nil
    end

    describe 'With user id' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_instance_with_user_id, secret_key: SECRET_KEY) }

      it 'parse user id' do
        expect(subject.uid).to eq '29d8204a-3b82-4a98-8d86-2464a6b836da'
      end

    end

    describe 'Owner Mode' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_in_owner_mode, secret_key: SECRET_KEY) }

      it 'parse user id' do
        expect(subject.uid).to eq '29d8204a-3b82-4a98-8d86-2464a6b836da'
      end

      it 'parse permissions' do
        expect(subject.permissions).to eq 'OWNER'
      end
    end
  end

  describe 'signature validation' do

    describe 'secret is nil' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_instance) }

      it 'raise SignedInstanceNoSecretKey' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceNoSecretKey
      end
    end

    describe 'incorrect signature' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_instance, secret_key: 'another-secret') }

      it 'raise SignedInstanceParseError' do
        expect { subject }.to raise_error Wix::Apps::SignedInstanceParseError
      end
    end

    describe 'valid signature' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_instance, secret_key: SECRET_KEY) }

      it 'should instantiate' do
        expect(subject).to be_instance_of Wix::Apps::SignedInstance
      end
    end

  end

  describe 'owner_permissions?' do
    describe 'without user id' do
      it 'return false' do
        expect(subject.owner_permissions?).to be false
      end
    end

    describe 'with user id' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_instance_with_user_id, secret_key: SECRET_KEY) }
      it 'return false' do
        expect(subject.owner_permissions?).to be false
      end
    end

    describe 'in owner mode' do
      subject { Wix::Apps::SignedInstance.new(raw_signed_in_owner_mode, secret_key: SECRET_KEY) }
      it 'return true' do
        expect(subject.owner_permissions?).to be true
      end
    end
  end
end