# Available frontmatter

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

## `owner_slack`

The Slack username or channel of the page owner. This can be used to appoint an individual or team as responsible for keeping the page up to date.

```yaml
---
owner_slack: "#operations-teams"
---
```
