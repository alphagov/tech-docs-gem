# Changelog

## 1.8.3

Fixes bug where search results disappear when opening results in a new tab, making it difficult to open several results in a batch (PR #86).

## 1.8.2

Adds a `show_expiry` config option to allow you to choose whether to show the review due date and expired banner from your pages. Find out more about the [page expiry and review feature][expiry].

[expiry]: https://tdt-documentation.london.cloudapps.digital/page-expiry.html#page-expiry-and-review

## 1.8.1

This release fixes a bug (#79 - reported in
[alphagov/tech-docs-template#183][tdt-183]) which prevented a multipage site
from being generated when a custom `http_prefix` was configured.

[tdt-183]: https://github.com/alphagov/tech-docs-template/issues/183

## 1.8.0

🎉 Our first contributor from outside of GDS. Thanks [@timja](https://github.com/timja) from [HMCTS](https://hmcts.github.io)! 🤝

New features: you can now configure a different GitHub branch for the repo to generate the "View source" link in the footer. Use `github_branch` in your config file (#71). You can also specify a `full_service_name` in the config, which is used in the browser title and meta tags (#72).

This version also fixes a bug with unclickable links (#74 - reported in [alphagov/tech-docs-template#123](https://github.com/alphagov/tech-docs-template/issues/123)).

## 1.7.0

New features: this release adds support for a full-width page (#63) and adding HTML to the `head` of the page (#64).

This release also makes sure that all pages are returned in the `/api/pages.json` endpoint (#66).

## 1.6.3

The gem now uses `middleman-search-gds` rather than `middleman-search`, which
removes the need for projects to point to the alphagov github repository in
their Gemfiles. We will continue to maintain our own fork until the changes
are merged into the upstream project.

## 1.6.2

This version fixes an issue with Middleman hanging (PR #54). It also allows the API reference page to include multiple servers and their descriptions (PR #53).

## 1.6.1

### Make `api_path` configuration optional

A bug in the previous release prevented the docs from being generated if
`api_path` was missing. This is now fixed.

## 1.6.0

Version 1.6.0 adds API reference generation, and improves the search function.

### New feature: API reference

Specify an OpenAPI spec file using `api_path`, for example: `api_path: source/pets.yml`.

To output the generated content in the page of your choice, write `api>` in any markdown parsed file (.md, .html.md, .html.md.erb). You can also specify to just print a specific path: `api> /pets`

This generates request and response schemas and examples for each API operation.

More info:

- https://github.com/alphagov/tech-docs-gem/pull/40
- https://github.com/alphagov/tech-docs-gem/pull/48

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

### Correct fork of middleman in example project

The example gem project now uses alphagov/middleman-search. This prevents `bundle exec middleman serve` from crashing.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/35

### Accessibility improvements

Accessibility improvements to search, collapsible navigation, and the logo.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/36
- https://github.com/alphagov/tech-docs-gem/pull/33

### Additional configuration options for review system

`default_owner_slack` and `owner_slack_workspace` are now configurable for use within the review system.

More info:
- https://github.com/alphagov/tech-docs-gem/pull/47

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

The search indexing pipeline has been tweaked to provide expected results. The display of the search results has also been improved.

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
