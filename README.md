# Cenit Multi Tenancy

Provides multi-tenancy functionality to store records using Mongoid

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cenit-multi_tenancy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cenit-multi_tenancy

## Usage

Include `Cenit::MultiTenancy` module into your tenant model: 

```ruby
class Account
    include Mongoid::Document
    include Cenit::MultiTenancy    
end
```

Include `Cenit::MultiTenancy::Scoped` in any model you want to store records for multiple tenants

```ruby
class Product
    include Mongoid::Document
    include Cenit::MultiTenancy::Scoped    
end
```

Your model will store records on different mongodb collections depending on the value of your current tenant record ID:

```ruby
Account.current = account1

Product.create # will store a record on collection accXXXXX_products collection, where XXXXX is the account1 record ID

Account.current = account2

Product.create # will store a record on collection accYYYYY_products collection, where YYYYY is the account2 record ID

Account.current = nil

Product.create # will store a record on the default collection products
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/cenit-io/cenit-multi_tenancy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
