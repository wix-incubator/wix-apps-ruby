require 'spec_helper'

describe Wix::Apps::SignedInstanceMiddleware do
  include Rack::Test::Methods

  let(:app) { lambda { |env| [200, {}, []] } }
  let(:secret) { 'd245bbf8-57eb-49d6-aeff-beff6d82cd39' }

  let(:middleware) { Wix::Apps::SignedInstanceMiddleware.new(app, secured_paths: ['/wix'],
                      secret_key: secret) }
  let(:mock_request) { Rack::MockRequest.new(middleware) }

  let(:instance) { 'HottEZ2jPjqsqS8sFWwngJDZAc5L6BBv5j5N9WAN0Go.eyJpbnN0YW5jZUlkIjoiYjgxNDBlNGQtNDc1ZC00OGVkLTgxOWYtYmFkMGRlNDQ3MDY5Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTExVDEzOjU2OjQ0LjYzNVoiLCJ1aWQiOm51bGwsInBlcm1pc3Npb25zIjpudWxsfQ' }
  let(:response) { mock_request.get('/wix', params: { 'instance' => instance }) }

  describe "Unsecured paths" do
    let(:response) { mock_request.get('/') }
    it("returns a 200") { response.status.should == 200 }
  end

  describe "Secured Paths" do
    describe "without instanse" do
      let(:response) { mock_request.get('/wix') }
      it("returns a 401") { response.status.should == 401 }
    end

    describe "with invalid instanse" do
      let(:instance) { 'invalid.instance' }
      it("returns a 403") { response.status.should == 403 }
    end

    describe "with valid instalnse" do
      it("returns a 200") { response.status.should == 200 }

      describe "instance parsing" do
        it "have instance_id" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['instance_id']
              .should eq('b8140e4d-475d-48ed-819f-bad0de447069')

            [200, {}, []]
          end

          response
        end

        it "have sign_date" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['sign_date']
              .should eq(DateTime.parse("2012-08-11T13:56:44.635Z"))
            [200, {}, []]
          end

          response
        end
      end

      describe "logined user" do
        let(:instance) { '0jepzq2Gi8zFxLdS_LhTuXIkmFR41H1QOstEtn1v4w0.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTEyVDEwOjA0OjE3Ljg1MloiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6bnVsbH0' }

        it "have user_id" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['user_id']
              .should eq('29d8204a-3b82-4a98-8d86-2464a6b836da')
            [200, {}, []]
          end

          response
        end

        it "don't have permissions" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['permissions']
              .should be_nil
            [200, {}, []]
          end

          response
        end
      end


      describe "owner" do
        let(:instance) { 'zPsXLAaMznRbzXUiBo51bNzjKhVRo-GU5U4wSqyxzIg.eyJpbnN0YW5jZUlkIjoiOWY5YzVjMTYtNTljOC00NzA4LThjMjUtODU1NTA1ZGFhOTU0Iiwic2lnbkRhdGUiOiIyMDEyLTA4LTEyVDEwOjExOjIyLjkzNFoiLCJ1aWQiOiIyOWQ4MjA0YS0zYjgyLTRhOTgtOGQ4Ni0yNDY0YTZiODM2ZGEiLCJwZXJtaXNzaW9ucyI6Ik9XTkVSIn0' }

        it "it have user_id" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['user_id']
              .should eq('29d8204a-3b82-4a98-8d86-2464a6b836da')
            [200, {}, []]
          end

          response
        end

        it "have permissions" do
          app.should_receive(:call) do |arg|
            arg['rack.request.query_hash']['parsed_instance']['permissions']
              .should eq('OWNER')
            [200, {}, []]
          end

          response
        end
      end
    end
  end
end