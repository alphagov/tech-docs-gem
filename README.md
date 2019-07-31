# Tech Docs Template - gem

This repo contains the Ruby gem that distributes the [Tech Docs Template][tdt-template]. The Tech Docs Template is a [middleman template][mmt] that
you can use to build technical documentation using a GOV.UK style.

👉 Find out more about the template and its features from the [Tech Docs Template documentation][tdt-docs].

## Usage

👉 Find out how to [generate a new website with the Tech Docs Template][tdt-readme].

## Contributing

Everybody who uses this project is encouraged to contribute.

👉 [See CONTRIBUTING.md](CONTRIBUTING.md) for guidance on making changes.

## GOV.UK frontend

This gem uses [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend), part of the [GOV.UK Design System](https://design-system.service.gov.uk/).

We use `npm` to download the govuk-frontend package. To update to a new version, change the version in [package.json](blob/master/package.json) and run `npm update`.

## Developing locally

There are 2 ways to develop with this gem. You can see your changes on either:

- your own Tech Docs Template website
- the example in this repository

### Use your own Tech Docs Template website

If you want to see how your changes to the gem affect your website, you have to point your site's Gemfile to your local checkout:

```rb
gem 'govuk_tech_docs', path: '../tech-docs-gem'
```

To view your changes locally run:

```sh
bundle exec middleman server
```

See your website on `http://localhost:4567` in your browser.

### Use the example in this repo

To start the example in this repo, run:

```sh
cd example
bundle install
bundle exec middleman server
```

See your website on `http://localhost:4567` in your browser.

## Tests

The repository contains automated JavaScript tests that use [Jasmine][jas] test framework.

To run the tests and see the results in your browser:

1. Run `bundle exec rake jasmine`
2. Go to `http://localhost:8888` in your browser

To run the tests and see the results in your terminal, run:

```
bundle exec rake jasmine:ci
```

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
[tdt-docs]: https://tdt-documentation.london.cloudapps.digital
[tdt-template]: https://github.com/alphagov/tech-docs-template
[tdt-readme]: https://github.com/alphagov/tech-docs-template/blob/master/README.md
[mmt]: https://middlemanapp.com/advanced/project_templates/

[jas]: https://jasmine.github.io/
