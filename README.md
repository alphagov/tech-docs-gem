# Tech Docs Template - gem

This repo is part of the GOV.UK Tech docs project. This repo contains the Ruby
gem that is used to distribute most of code that is used to generate the site.

👉 [See alphagov.github.io/tech-docs-manual](https://alphagov.github.io/tech-docs-manual)

## Usage

To [generate a new site with the template](https://alphagov.github.io/tech-docs-manual/#create-a-new-site), see the manual.

## Contributing

👉 [See CONTRIBUTING.md](CONTRIBUTING.md)

## Developing locally

There are 2 ways to develop with this gem.

The first is to point your site's Gemfile to your local checkout, and use it normally. This is good for if you want to see what effect your changes have to the actual site.

```rb
gem 'govuk_tech_docs', path: '../tech-docs-gem'
```

The second is to use the example app in this repo. You can start it by

```
cd example
bundle install
bundle exec middleman serve
```

Your site will appear on <http://localhost:4567>.

## Tests

We have some automated JavaScript tests that use [Jasmine][jas] as a test
framework.

To run the tests on your machine:

- Run `bundle exec rake jasmine`
- Navigate to `http://localhost:8888` in a browser of your choosing
- Peruse the output of your tests

Or, on the command line, run `bundle exec rake jasmine:ci`.

## Releasing new versions

To release a new version, create a new Pull Request that updates [version.rb](lib/govuk_tech_docs/version.rb) and [CHANGELOG.md](CHANGELOG.md). Don't mix this in with other changes - this makes it easier to find out what was released when. See [this PR to release a new version as an example](https://github.com/alphagov/tech-docs-gem/pull/15).

Travis will automatically release a [new version to Rubygems.org](https://rubygems.org/gems/govuk_tech_docs).

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit].
This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/

[jas]: https://jasmine.github.io/
