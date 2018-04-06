# Layouts

There are 2 available page layouts.

## `layout` layout

By default, pages will use the `layout` layout. This layout will parse the page and generate a sidebar with a table of contents consisting of each `h2`, `h3`, `h4` heading.

```md
---
layout: layout
---

# The title

## A subheader

### A h3 subheader

## Another subheader
```

Will generate a page with the headings from the content in the sidebar.

![](layout-layout.png)

## `core` layout

If you want more control about the layout, use `core` layout. This allows you to specify the sidebar manually with a `content_for` block.

```rb
---
layout: core
---

<% content_for :sidebar do %>
  You can put anything in the sidebar.
<% end %>

This page has a configurable sidebar that is independent of the content.
```

![](core-layout.png)
