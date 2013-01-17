# Wix::Apps
[![Build Status](https://secure.travis-ci.org/wix/wix-apps-ruby.png?branch=master)](http://travis-ci.org/wix/wix-apps-ruby)

Rack middleware for use with "Third Party Applications".
It checks signature and passes the parsed_instance param to your application.

## Installation

Add this line to your application's Gemfile:

    gem 'wix-apps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wix-apps

## Usage

### Any Rack Application
Add Wix::Apps::SignedInstanceMiddleware as any other middleware.
```ruby
use Wix::Apps::SignedInstanceMiddleware, secured_paths: ['/yours', '/paths'], secret_key: 'secret_key'
```
### Rails
In application.rb, add:
```ruby
config.middleware.use Wix::Apps::SignedInstanceMiddleware,
  secured_paths: ['/yours', '/paths'], secret_key: 'your-secret-key'
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
