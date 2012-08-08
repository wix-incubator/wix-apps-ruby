require 'bundler/setup'
Bundler.require(:default, :development)

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each {|f| require f}