# Wix::Apps
[![Build Status](https://secure.travis-ci.org/wix/wix-apps-ruby.png?branch=master)](http://travis-ci.org/wix/wix-apps-ruby)

Rack middleware for use with "Third Party Applications" on the Wix platform.
It handles the instance param passed by Wix requests for configurable paths. It checks the signature, parses the contents and passes a convenient Object to your application via env.

## Installation

Important note: if you're using a pre-1.0.0-version of this gem, please be aware the API changed significantly. You will have to update some of your code. However, in versions >= 1.0.0 should be a corresponding method for anything from version 0.0.x.

Add this line to your application's Gemfile:

    gem 'wix-apps', '~> 1.0.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wix-apps

## Usage

### Any Rack Application
Add `Wix::Apps::SignedInstanceMiddleware` like any other middleware.
```ruby
use Wix::Apps::SignedInstanceMiddleware, secret_key: 'secret_key',
  secured_paths: ['/your', '/paths', %r{\A/wix/(auth|update)\z}]
```
### Rails
In `application.rb`, add:
```ruby
config.middleware.use Wix::Apps::SignedInstanceMiddleware, secret_key: 'your-secret-key',
  secured_paths: ['/wix']
```

In your controller handling a configured secured path, access the signed instance:
```ruby
class WixController < ApplicationController
    def index
        # retrieve Wix::Apps::SignedInstance object
        instance = request.env['wix.instance']
        
        if instance.owner_permissions? 
        ...
```

### env['wix.instance']
This WixApps middleware passes on a `Wix::Apps::SignedInstance` object through env['wix.instance']. The object has the following methods:

Object method | Type | Description
------------- | ---- | -----------
instance_id | String | Required Wix instance property `instanceId`
sign_date | DateTime | Required Wix instance property `signDate`
uid | String | Optional Wix instance property `uid`
permissions | String | Required Wix instance property `permissions`
ip_and_port | String | Required Wix instance property `ipAndPort`
vendor_product_id | String | Required Wix instance property `vendorProductId`
aid | String | Required Wix instance property `aid`
origin_instance_id | String | Optional Wix instance property `originInstanceId`
site_owner_id | String | Required Wix instance property `siteOwnerId`
owner_permissions? | Boolean | Indicates if instance user has owner (includes site administrators) permissions
owner_logged_in? | Boolean | Indicates if instance user is the single owner of the site

### Options

#### secured_paths
An Array of String- and Regexp-objects describing the paths to be secured by checking the Wix signed instance. On request, the path will be checked against every entry in this list. Strings are checked for equality, Regexps are matched (without additional conditions, so use \A and \z for start and end markers if you need them!). Keep in mind rack's paths always begin with a '/'.

Example (secures '/auth_path', every path containing the string 'wix' and every path starting with '/wox/'):

    secured_paths: ['/auth_path', /wix/, %r{\A/wox/}]
 
#### paths
Just like secured_paths, except these paths may or may not receive a Wix signed instance. If it does, the instance has to be valid. Calling `request.env('wix.instance')` in the controller may return nil (although the env key `'wix.instance'` exists) if there was no instance passed.
 
#### secret_key
A String containing your Wix app's secret key.

Example:

    secret_key: 'd245bbf8-57eb-49d6-aeff-beff6d82cd39'

#### (optional) strict_properties
A Boolean indicating if the instance properties of the Wix signed instance should be checked for completeness (true, default) or not (false). You should never need to set it to false and it's meant for debugging purposes only. 

Example:

    strict_properties: true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
