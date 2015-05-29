module Wix
  module Apps
    class SignedInstanceMiddleware < Struct.new :app, :options
      def initialize(app, options={})
        @app = app
        initialize_options options
      end

      def call(env)
        @env = env

        if secured_path?
          @request = Rack::Request.new(env)
          if have_instance?
            begin
              @instance = Wix::Apps::SignedInstance.new(@request.params['instance'],
                          secret: options[:secret_key])
            rescue Wix::Apps::SignedInstanceParseError => e
              return [403, {}, ['Invalid wix instance']]
            end

            if @instance.valid?
              parse_instance!
              @app.call(env)
            else
              [403, {}, ['Invalid wix instance']]
            end
          else
            [401, {}, ['Unauthorized']]
          end
        else
          @app.call(env)
        end

      end

      private
      def initialize_options(options={})
        self.options = {
          :secret_key => nil,
          :secured_paths => []
        }.merge(options)
      end

      def secured_path?
        options[:secured_paths].include? @env['PATH_INFO']
      end

      def have_instance?
        @request.params.keys.include? 'instance'
      end

      def parse_instance!
        parsed_instance = {
          'instance_id' => @instance.instance_id,
          'sign_date' => @instance.sign_date,
          'user_id' => @instance.uid,
          'permissions' => @instance.permissions,
          'vendor_product_id' => @instance.vendor_product_id
        }
        @request.GET['parsed_instance'] = parsed_instance

      end
    end
  end
end