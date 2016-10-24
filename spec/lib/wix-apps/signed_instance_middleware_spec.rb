require 'spec_helper'

def in_middleware
  expect(app).to receive(:call) do |env|
    yield(env)
    [200, {}, []]
  end

  response
end

describe Wix::Apps::SignedInstanceMiddleware do
  include Rack::Test::Methods

  let(:app) { lambda { |env| [200, {}, []] } }
  let(:secret) { 'd245bbf8-57eb-49d6-aeff-beff6d82cd39' }
  let(:middleware) { Wix::Apps::SignedInstanceMiddleware.new(
    app,
    secured_paths: ['/wix', %r{\A/secured_paths_\d+\z}],
    paths: ['/wix_path', %r{\A/paths_\d+\z}],
    secret_key: secret)
  }
  let(:mock_request) { Rack::MockRequest.new(middleware) }
  let(:instance) { sign(params_required) }

  describe 'a request to an unsecured path' do
    let(:response) { mock_request.get('/') }
    it('returns a 200') do
      expect(response.status).to eq 200
    end
  end

  describe 'a request to' do

    shared_examples_for 'a request to a path' do
      describe 'without an instance' do
        let(:response) { mock_request.get(path) }

        it('returns a 200') do
          expect(response.status).to eq 200
        end

        it 'contains the instance key in the env' do
          in_middleware { |env| expect(env.has_key?('wix.instance')).to eq true }
        end

        it 'contains a nil instance in env' do
          in_middleware { |env| expect(env['wix.instance']).to be_nil }
        end

      end

      let(:response) { mock_request.get('/wix_path', params: {'instance' => instance}) }

      describe 'with an empty instance' do
        let(:instance) { nil }

        it('returns a 403') do
          expect(response.status).to eq 403
        end

      end

      describe 'with a valid anonymous instance' do

        let(:instance) { sign(params_required) }

        it('returns a 200') do
          expect(response.status).to eq 200
        end

        it 'contains the instance key in the env' do
          in_middleware { |env| expect(env.has_key?('wix.instance')).to eq true }
        end

        it 'has an instance_id' do
          in_middleware { |env| expect(env['wix.instance'].instance_id).to eq params_required[:instanceId] }
        end

      end
    end

    describe 'a path matched statically' do
      let(:path) { '/wix_path' }
      it_behaves_like 'a request to a path'
    end

    describe 'a path matched by regex' do
      let(:path) { '/paths_9' }
      it_behaves_like 'a request to a path'
    end

    shared_examples_for 'a request to a secured path' do
      describe 'without an instance' do
        let(:response) { mock_request.get(path) }
        it('returns a 401') do
          expect(response.status).to eq 401
        end
      end

      describe 'with an invalid instance' do
        let(:instance) { 'invalid.instance' }
        it('returns a 403') do
          expect(response.status).to eq 403
        end
      end

      describe 'with an empty instance' do
        let(:instance) { nil }
        it('returns a 403') do
          expect(response.status).to eq 403
        end
      end

      let(:response) { mock_request.get(path, params: {'instance' => instance}) }

      describe 'with a valid anonymous instance' do
        it('returns a 200') do
          expect(response.status).to eq 200
        end

        it 'has an instance_id' do
          in_middleware { |env| expect(env['wix.instance'].instance_id).to eq params_required[:instanceId] }
        end

      end

      describe 'with a valid logged in instance' do
        let(:params_with_user) {
          params_required.merge(uid: 'c713982b-9161-49bc-9ff5-67502e4b705b')
        }

        let(:instance) { sign(params_with_user) }

        it 'has a user_id' do
          in_middleware { |env| expect(env['wix.instance'].uid).to eq params_with_user[:uid] }
        end

        it 'does not have permissions' do
          in_middleware { |env| expect(env['wix.instance'].permissions).to eq '' }
        end
      end

      describe 'with a valid owner instance' do

        let(:params_with_owner) {
          params_required.merge(uid: '92771668-366f-4ec6-be21-b32c78e7b734', permissions: 'OWNER')
        }

        let(:instance) { sign(params_with_owner) }

        it 'have a user_id' do
          in_middleware { |env| expect(env['wix.instance'].uid).to eq params_with_owner[:uid] }
        end

        it 'have permissions' do
          in_middleware { |env| expect(env['wix.instance'].permissions).to eq params_with_owner[:permissions] }
        end
      end
    end

    describe 'a secured path matched staically' do
      let(:path) { '/wix' }
      it_behaves_like 'a request to a secured path'
    end

    describe 'a secured path matched by regex' do
      let(:path) { '/secured_paths_10' }
      it_behaves_like 'a request to a secured path'
    end

  end

end
