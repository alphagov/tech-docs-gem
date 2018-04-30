# Tech Docs Template - gem

This repo is part of the [tech-docs-template](https://github.com/alphagov/tech-docs-template).

## Usage

To [generate a new site with the template](https://github.com/alphagov/tech-docs-template#creating-a-new-documentation-project), see the tech-docs-template repo.

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

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

[jas]: https://jasmine.github.io/
