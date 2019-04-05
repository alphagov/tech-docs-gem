# Configuration

You can configure the site using `config/tech-docs.yml`. [See the PaaS tech docs for an example](https://github.com/alphagov/paas-tech-docs/blob/master/config/tech-docs.yml).

These are all the available options:

## `ga_tracking_id`

Tracking ID from Google Analytics

```yaml
ga_tracking_id: UA-XXXX-Y
```

## `github_repo`

Your repository. Required if [show_contribution_banner](#show-contribution-banner) is true.

```yaml
github_repo: alphagov/example-repo
```

## `github_branch`

Your github branch name. Useful if your default branch is not named master.

```yaml
github_branch: source
```

## `google_site_verification`

Adds a [Google Site Verification code](https://support.google.com/webmasters/answer/35179?hl=en) to the meta tags.

```yaml
google_site_verification: TvDTuyvdstyusadrCSDrctyd
```

## `enable_search`

Enables search functionality. This indexes pages only and is not recommended for single-page sites.

```yaml
enable_search: true
```

## `header_links`

Right hand side navigation.

Example:

```yaml
header_links:
  Documentation: /
```

## `host`

Host to use for canonical URL generation (without trailing slash).

Example:

```yaml
host: https://docs.cloud.service.gov.uk
```

## `collapsible_nav`

Enable collapsible navigation in the sidebar. Defaults to false;

```yaml
collapsible_nav: true
```

## `multipage_nav`

Enable multipage navigation in the sidebar. Defaults to false;

```yaml
multipage_nav: true
```

## `max_toc_heading_level`

Table of contents depth – how many levels to include in the table of contents. If your ToC is too long, reduce this number and we'll only show higher-level headings.

```yaml
max_toc_heading_level: 6
```

## `phase`

```yaml
phase: "Beta"
```

## `prevent_indexing`

Prevent robots from indexing (e.g. whilst in development)

```yaml
prevent_indexing: false
```

## `redirects`

A list of redirects, from old to new location. Use this to set up external
redirects or if [setting `old_paths` in the frontmatter](docs/frontmatter.md#old_paths) doesn't work.

```yaml
redirects:
  /old-page.html: https://example.org/something-else.html
  /another/old-page.html: /another/new-page.html
```

## `service_name`

The service name in the header.

Example:

```yaml
service_name: "Platform as a Service"
```

## `full_service_name`

The full service name (maybe with GOV.UK)

Example:

```yaml
full_service_name: "GOV.UK Pay"
```

## `service_link`

What the service name in the header links to.

default: '/'

```yaml
service_link: "/"
```

## `show_contribution_banner`

Show a block at the bottom of the page that links to the page source, so readers
can easily contribute back to the documentation. If turned on [github_repo](#github-repo) is
required.

Off by default.

```yaml
show_contribution_banner: true
github_repo: alphagov/example-repo
```

## `source_urls`

Customise the URLs that the contribution banner links to. Only useful if
[show_contribution_banner](#show_contribution_banner) is turned on. By default, "Report issue" links
to raising a GitHub issue but by modifying the `report_issue_url` it can link to an email address
or another page.

```yaml
source_urls:
  report_issue_url: mailto:support@example.com
```

## `show_govuk_logo`

Whether to show the GOV.UK crown logo.

default: `true`

```yaml
show_govuk_logo: true
```

## `api_path`

Define a path to an Open API V3 spec file. This can be a relative file path or a URI to a raw file.

```yaml
api_path: ./source/pets.yml
```

## `owner_slack_workspace` and `default_owner_slack`

These attributes are used to specify the owner of a page.  See the separate
[documentation for page expiry][expiry] for more details.

## `show_expiry`

Decides whether or not to show a red banner when the page needs to be reviewed.

If not present or set to `true`, the red banner will appear when the page needs to be reviewed. This is the default behaviour.

If set to `false`, the red banner will not appear when the page needs to be reviewed.

See the separate [documentation for page expiry][expiry] for more details.

[expiry]: https://tdt-documentation.london.cloudapps.digital/page-expiry.html#page-expiry-and-review
