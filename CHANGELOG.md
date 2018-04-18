# Changelog

## Unreleased

You can now pass options into `GovukTechDocs.configure` for the `livereload`
extension.

```rb
GovukTechDocs.configure(self, livereload: { js_host: 'localhost' })
```

## 1.2.0

### New feature: redirects

You can now specify redirects in the frontmatter and `config/tech-docs.yml`.

You can use this when you change a page URL.

More info:

- https://github.com/alphagov/tech-docs-gem/blob/master/docs/configuration.md#redirects
- https://github.com/alphagov/tech-docs-gem/blob/master/docs/frontmatter.md#old_paths

### New feature: contribution banner

You can now show a block at the bottom of the page that links to
the page source on GitHub, so readers can easily contribute back to the documentation.

https://github.com/alphagov/tech-docs-gem/blob/master/docs/configuration.md#show_contribution_banner

### New feature: page review system

An optional page review system to make sure documentation stays up to date.

More info:

- https://github.com/alphagov/tech-docs-gem/blob/master/docs/frontmatter.md#last_reviewed_on
- https://github.com/alphagov/tech-docs-gem/blob/master/docs/frontmatter.md#owner_slack


### Better meta tags

Pages now include better meta tags for search engines, Twitter, Facebook and Slack to pick up.

## 1.1.0

You can now specify `google_site_verification` in tech-docs.yml. You can use
this to verify your site in Google Webmaster tools.

https://github.com/alphagov/tech-docs-gem/blob/master/docs/configuration.md#google_site_verification

## 1.0.0

The first release of the template as a gem. Most CSS, JS, images and layouts are
now imported from the gem and can be removed from your project.

The following script upgrades your project. This will work if you've not made
any modifications to the files distributed by the template. If you have, you'll
need to port your changes back in.

```sh
rm -rf lib source/images source/layouts source/favicon.ico source/javascripts/* source/stylesheets/*

echo "//= require govuk_tech_docs" > source/javascripts/application.js
echo "@import 'govuk_tech_docs';" > source/stylesheets/screen.css.scss

echo '$is-print: true;

@import "govuk_tech_docs";' > source/stylesheets/print.css.scss

echo '$is-ie: true;
$ie-version: 8;

@import "govuk_tech_docs";' > source/stylesheets/screen-old-ie.css.scss

echo "require 'govuk_tech_docs'

GovukTechDocs.configure(self)" > config.rb

echo "source 'https://rubygems.org'

# For faster file watcher updates on Windows:
gem 'wdm', '~> 0.1.0', platforms: [:mswin, :mingw]

# Windows does not come with time zone data
gem 'tzinfo-data', platforms: [:mswin, :mingw, :jruby]

gem 'govuk_tech_docs'" > Gemfile

bundle install
```
