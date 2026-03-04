# Tech Docs Template - gem

This repo contains the Ruby gem that distributes the [Tech Docs Template][tdt-template]. The Tech Docs Template is a [middleman template][mmt] that
you can use to build technical documentation using a GOV.UK style.

To find out more about setting up and managing content for a website using this template, see the [Tech Docs Template documentation][tdt-docs].

## Contributing

Everybody who uses this project is encouraged to contribute.

Find out how to [contribute](https://tdt-documentation.london.cloudapps.digital/support/#contribute).

## GOV.UK frontend

This gem uses [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend), part of the [GOV.UK Design System](https://design-system.service.gov.uk/).

We use `npm` to download the govuk-frontend package. To update to a new version, change the version in the [package.json file](package.json) and run `npm update`.

## Use layouts to structure your Table of Contents

You can use layouts to group pages and customise your Table of Contents (ToC).  To create a template create a new ruby file in the `source/layouts` directory, for example `source/layouts/live_support_layout.erb`.  You can apply the template by including it in the frontmatter block of your required pages, for example:

```diff
    ---
    title: Live support rota
    weight: 1
    last_reviewed_on: 1970-01-01
    review_in: 3 months
+   layout: live_support_layout 
    ---
```


This gem has helper functions to render your ToC.  You should use:

- `single_page_table_of_contents` to create a ToC from the headings on the current page
- `multi_page_table_of_contents` to create a ToC for a group of pages, opened at the current page

The `multi_page_table_of_contents`  helper function takes [an optional `include_child_resources`](https://github.com/alphagov/tech-docs-gem/pull/439) parameter to help with your custom ToC.  The default value of `include_child_resources` is `true`.

Below is an example of using the helper functions in a custom layout:

```
<%
wrap_layout :core do

  content_for(:toc_module, "in-page-navigation")

  use_multipage_nav = current_page.data.fetch(:multipage_nav, config[:tech_docs][:multipage_nav])

  content_for :sidebar do
    if use_multipage_nav %>
      <%= multi_page_table_of_contents(sitemap.resources[1], current_page, config, yield, include_child_resources: false) %>
    <% else %>
      <%= single_page_table_of_contents(yield, max_level: config[:tech_docs][:max_toc_heading_level]) %>
    <% end %>
  <%
  end

  html
end
%>
```

## Developing locally

There are 2 ways to develop with this gem. You can see your changes on either:

- your own Tech Docs Template website
- the example in this repository

### Use your own Tech Docs Template website

To see how your changes to the gem affect your website, point your website's Gemfile to your local checkout:

```rb
gem 'govuk_tech_docs', path: '../tech-docs-gem'
```

To preview your documentation changes locally, see the [Tech Docs Template documentation on previewing your documentation](https://tdt-documentation.london.cloudapps.digital/create_project/preview/#preview-your-documentation).

If you experience [the FFI gem issue for Mojave users](https://github.com/alphagov/tech-docs-gem/issues/254), you should refer to this [list of possible fixes](#issue-with-ffi-on-osx-mohave).

### Use the example in this repo

To start the example in this repo, run:

```sh
cd example
bundle install
bundle exec middleman server
```

See your website on `http://localhost:4567` in your browser.

If you experience [the FFI gem issue for Mojave users](https://github.com/alphagov/tech-docs-gem/issues/254), you should refer to this [list of possible fixes](#issue-with-ffi-on-osx-mohave).

For more information on previewing your documentation locally, see the [Tech Docs template documentation on previewing your documentation](https://tdt-documentation.london.cloudapps.digital/create_project/preview/#preview-your-documentation).

## Tests

This repository contains automated JavaScript tests that use the [Jasmine test framework][jas].

You can run these tests and see the results in your browser.

1. Run `bundle exec rake jasmine`.
2. Go to `http://localhost:8888` in your browser.

To run the tests and see the results in your terminal, run:

```
bundle exec rake jasmine:ci
```

## Issue with FFI on OSX Mojave

Users on OSX Mojave (10.14) may get this error when running `bundle exec middleman serve` on apps that use this gem.

There are 3 possible ways to solve this. From best to worst, you can:

* upgrade to macOS 10.15 (Catalina) or higher
* tell rubygems not to use the system ffi by running `gem install ffi -- --disable-system-libffi` in the command line when the error shows
* pin the ffi version back to 1.12.2 by editing the Gemfile of your app

## Releasing new versions

To release a new version, create a new pull request (PR) that updates [version.rb](lib/govuk_tech_docs/version.rb) and [CHANGELOG.md](CHANGELOG.md).

Do not include other changes in your pull request, as this makes it easier to find out what was released when. See an example of a [PR for releasing a new version](https://github.com/alphagov/tech-docs-gem/pull/15).

Travis will automatically release a [new version to Rubygems.org](https://rubygems.org/gems/govuk_tech_docs).

## Licence

Unless stated otherwise, the codebase is released under [the MIT License][mit]. This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright][copyright] and available under the terms of the [Open Government 3.0][ogl] licence.

[mit]: LICENCE
[copyright]: http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/
[ogl]: http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
[tdt-docs]: https://tdt-documentation.london.cloudapps.digital
[tdt-template]: https://github.com/alphagov/tech-docs-template
[tdt-readme]: https://github.com/alphagov/tech-docs-template/blob/main/README.md
[mmt]: https://middlemanapp.com/advanced/project_templates/

[jas]: https://jasmine.github.io/
