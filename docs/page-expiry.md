# Page Expiry and Review Notices

It's possible to include frontmatter configuration for a page to set an
expiration date for a piece of content.

If the page doesn't need to be reviewed, we show a blue box with the
last-reviewed date, when it needs review again, and the owner.

![](not-expired-page.png)

If the page needs to be reviewed, we show a red box saying the page might not
be accurate.

![](expired-page.png)

This feature relies on JavaScript being enabled on the user's browser to
display the relevant notices.


## Frontmatter configuration

### `last_reviewed_on` and `review_in`

These attributes determine the date when the page needs to be reviewed next.

```yaml
---
last_reviewed_on: 2018-01-18
review_in: 6 weeks
---
```

You can use this in combination with `owner_slack` or `default_owner_slack` to
set an owner for the page.

### `owner_slack`

The Slack username or channel of the page owner. This can be used to appoint an
individual or team as responsible for keeping the page up to date.


## Global configuration

### `owner_slack_workspace`

The Slack workspace name used when linking to the Slack owner of a piece of
content. If not provided, the owner of a piece of content (channel or user)
won't be linked.

```yaml
owner_slack_workspace: gds
```

### `default_owner_slack`

The default Slack user or channel name to show as the owner of a piece of
content. Can be overridden using the `owner_slack` frontmatter config option.

```yaml
default_owner_slack: '#owner'
```


## Page API

The expiry date for each page is also shown in the `/api/pages.json`
representation of all pages.  This is used by the
[tech-docs-notifier](https://github.com/alphagov/tech-docs-notifier) to post
messages to Slack when pages have expired.
