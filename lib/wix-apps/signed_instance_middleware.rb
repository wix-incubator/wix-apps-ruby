module Wix
  module Apps
    class SignedInstanceMiddleware < Struct.new :app, :secret_key, :secured_paths, :paths

      # Initializes the middleware to secure a given set of paths.
      # Options:
      # :secret_key - the Wix secret key as String
      # :secured_paths (optional) - an Array of String and Regexp objects which every request's path is matched against. Matching paths are required to pass a Wix signed instance.
      def initialize(app, options={})
        self.app = app
        self.secret_key = options[:secret_key]
        self.secured_paths = options[:secured_paths] || []
        self.paths = options[:paths] || []
      end

      # Checks current URL path for Wix instance requirement, parses given signed instance and adds GET param 'parsed_instance' with the instance's parsed properties.
      # @param [Hash] env The current environment hash
      # @return [Array] The typical [<code>, <headers>, <body>] rack response Array
      def call(env)
        path = env['PATH_INFO']

        secured_path = secured_path? path
        if secured_path || path?(path)
          # path must be handled (instance is either required or optional)
          request = Rack::Request.new(env)

          env['wix.instance'] = nil
          if request.params.has_key? 'instance'
            # Wix' "instance" parameter was supplied so it must be parseable. parse and set it into env.
            begin
              env['wix.instance'] = Wix::Apps::SignedInstance.new(request.params['instance'], secret: secret_key)
            rescue Wix::Apps::SignedInstanceParseError
              # 403 Forbidden
              return [403, {}, ['Invalid Wix instance']]
            end
          elsif secured_path
            # instance is required but Wix' "instance" parameter is missing
            # 401 Unauthorized
            return [401, {}, ['Unauthorized']]
          end
        end
        app.call(env)
      end

      private

      # Check if a request URL's path should be required to pass a Wix signed instance or not. Checks the path against the secured_paths option.
      # @param [String] path URL path (=directory part) to check
      # @return [Boolean] Indicates if given path should be secured or not
      def secured_path?(path)
        path_match? secured_paths, path
      end

      # Check if a request URL's path should be checked for a Wix signed instance or not. Checks the path against the paths option.
      # @param [String] path URL path (=directory part) to check
      # @return [Boolean] Indicates if given path should be checked or not
      def path?(path)
        path_match? paths, path
      end

      def path_match?(match_paths, path)
        match_paths.any? { |match_path|
          case match_path.class.to_s
            when 'String'
              match_path == path
            when 'Regexp'
              match_path.match path
            else
              false
          end
        }
      end

    end
  end
end
