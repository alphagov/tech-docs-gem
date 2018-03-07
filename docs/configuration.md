# Configuration

You can configure the site using `config/tech-docs.yml`. [See the PaaS tech docs for an example](https://github.com/alphagov/paas-tech-docs/blob/master/config/tech-docs.yml).

These are all the available options:

## `host`

Host to use for canonical URL generation (without trailing slash).

Example:

```yaml
host: https://docs.cloud.service.gov.uk
```

## `show_govuk_logo`

Whether to show the GOV.UK crown logo.

default: `true`

```yaml
show_govuk_logo: true
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

## `phase`

```yaml
phase: "Beta"
```

## `header_links`

Right hand side navigation.

Example:

```yaml
header_links:
  Documentation: /
```

## `prevent_indexing`

Prevent robots from indexing (e.g. whilst in development)

```yaml
prevent_indexing: false
```

## `ga_tracking_id`

Tracking ID from Google Analytics

```yaml
ga_tracking_id: UA-XXXX-Y
```

## `max_toc_heading_level`

Table of contents depth – how many levels to include in the table of contents. If your ToC is too long, reduce this number and we'll only show higher-level headings.

```yaml
max_toc_heading_level: 6
```

## `google_site_verification`

Adds a [Google Site Verification code](https://support.google.com/webmasters/answer/35179?hl=en) to the meta tags.

```yaml
google_site_verification: TvDTuyvdstyusadrCSDrctyd
```
