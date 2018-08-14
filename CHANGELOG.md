# Changelog

## 1.5.1

### Correct fork of middleman in example project

The example gem project now uses alphagov/middleman-search. This prevents `bundle exec middleman serve` from crashing.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/35

### Accessibility improvements

Accessibility improvements to search, collapsible navigation, and the logo.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/36
- https://github.com/alphagov/tech-docs-gem/pull/33

### Search result improvements

The search indexing pipeline has been tweaked to provide expected results. The display of the search results has also been

If you're using search then you'll need to add this line to your project `Gemfile`:

```
gem 'middleman-search', git: 'git://github.com/alphagov/middleman-search.git'
```

More info:
- https://github.com/alphagov/tech-docs-gem/pull/37
- https://github.com/alphagov/tech-docs-gem/pull/38
- https://github.com/alphagov/tech-docs-gem/pull/41
- https://github.com/alphagov/tech-docs-gem/pull/42
- https://github.com/alphagov/tech-docs-gem/pull/43

## 1.5.0

### New feature: Search

Adds search functionality. This indexes pages only and is not recommended for single-page sites. To enable write `enable_search: true` in in tech-docs.yml.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/28

### Google Analytics tracking for old headings

An event category 'Broken fragment ID' will be pushed to Google Analytics when a user lands on a page with a URL that points to a fragment ID that does not exist on the page.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/30

## 1.4.0

Adds multiple page navigation support and collapsible top level navigation
items. When enabled the table of contents will display other pages on the site.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/27

## 1.3.1

Minor update to Google Analytics tracking

More info:
- https://github.com/alphagov/tech-docs-gem/pull/25

## 1.3.0

Version 1.3.0 contains accessibility fixes (#20) and a fix to make the
site more robust when certain options aren't set in the configs (#17).

### New feature: passing options to `GovukTechDocs.configure`

You can now pass options into `GovukTechDocs.configure` for the `livereload`
extension.

```rb
GovukTechDocs.configure(self, livereload: { js_host: 'localhost' })
```

See PR #18.

### New feature: page parents

You can now specify a page’s parent in its frontmatter. This affects
which item is selected in the navigation.

More info:

- https://github.com/alphagov/tech-docs-gem/pull/19
- https://github.com/alphagov/tech-docs-gem/blob/master/docs/frontmatter.md#parent

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
