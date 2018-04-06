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

## `google_site_verification`

Adds a [Google Site Verification code](https://support.google.com/webmasters/answer/35179?hl=en) to the meta tags.

```yaml
google_site_verification: TvDTuyvdstyusadrCSDrctyd
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

## `show_govuk_logo`

Whether to show the GOV.UK crown logo.

default: `true`

```yaml
show_govuk_logo: true
```
