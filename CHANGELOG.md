# Changelog

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

TechDocs.configure(self)" > config.rb

echo "source 'https://rubygems.org'

gem 'govuk_tech_docs', path: '../govuk_tech_docs'" > Gemfile

bundle install
```
