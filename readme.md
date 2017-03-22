# About

This repository contains the ruby client library for the GLS Europe Track&Trace HTTPS SOAP API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gls_track_and_trace'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gls_track_and_trace

## Usage

```ruby
# instantiate client
@client = GlsTrackAndTrace::Client.new('myusername', 'mypassword')

# get package details
begin
  package_details = @client.get_package_details('12345678900')
  package_details.delivered_at # Time object or nil
  # ...
rescue GlsTrackAndTrace::NoDataFoundError => e
  # Package not found or not yet in the system  
end

# package details attributes:
# package_number
# national_reference
# consignee_address
# shipper_address
# requester_address
# delivered_at
# picked_at
# product
# weight
# customer_reference
# package_history

package_history = package_details.package_history

# contains array of PackageHistory objects
# package history attributes:
# date
# location_code
# location_name
# country_name
# code
# description
```

## Contributing

1. Fork it ( https://github.com/Mixit-cz/gls_track_and_trace )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
