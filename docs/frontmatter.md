# Available frontmatter

"Frontmatter" allows page-specific variables to be included at the top of a template using YAML.

For a general introduction on frontmatter, see the [Middleman frontmatter docs][mm].

## `last_reviewed_on`

And `review_in`.

These 2 attributes determine the date when the page needs to be reviewed next.

If the page doesn't need to be reviewed, we show a blue box with the last-reviewed date, when it needs review again, and the owner.

![](not-expired-page.png)

If the page needs to be reviewed, we show a red box saying the page might not be accurate.

![](expired-page.png)

Example:

```yaml
---
last_reviewed_on: 2018-01-18
review_in: 6 weeks
---
```

You can use this in combination with `owner_slack` to set an owner for the page.

## `layout`

The layout of the page. See the [layout documentation](layouts.md) for the options.

## `old_paths`

Any paths of pages that should redirect to this page.

Example:

```yaml
---
old_paths:
  - /some-old-page.html
---
```

## `owner_slack`

The Slack username or channel of the page owner. This can be used to appoint an individual or team as responsible for keeping the page up to date.

```yaml
---
owner_slack: "#operations-teams"
---
```

## `title`

The browser title of the page.

[mm]: https://middlemanapp.com/basics/frontmatter
