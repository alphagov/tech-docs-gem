# Content examples

This page provides examples of different content types.

## Headings

```bash
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

## Ordered list

```bash
1. list item 1
1. list item 2
1. list item 3
...
1. list item N
```

## Unordered list

```bash
- list item 1
- list item 2
- list item 3
...
- list item N
```

## Tables

You can create tables using either markdown or HTML.

Use markdown when there are no specific formatting requirements.

Use HTML when there are specific formatting requirements, for example to ensure that text in cells do not wrap.

### Create table using markdown

Use markdown when there are no specific formatting requirements.

This example is a left-aligned table.

You should include `<div style="height:1px;font-size:1px;">&nbsp;</div>` before and after each table.

```bash
<div style="height:1px;font-size:1px;">&nbsp;</div>
```
```bash
|Column header|Column header|
|:---|:---|
|content|content|
|content|content|
```
```bash
<div style="height:1px;font-size:1px;">&nbsp;</div>
```

You can change the alignment of the text:

- Centre: `|:---:|`
- Right: `|---:|`

Add more columns and rows as needed.

### Create table using HTML

You should create tables using HTML when there are specific formatting requirements.

The following code is an example of a 2 column 2 row table with no text wrapping.

```bash
<div style = "overflow-x:auto;"> 
<table style="width:100%">
<tr>
<th nowrap>Header 1</th>
<th>Header 2</th>
</tr>
<tr>
<td nowrap><code>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin et enim quis arcu pharetra aliquet. Maecenas posuere tellus arcu, a suscipit dui posuere eu. Nunc vestibulum ligula sit amet eros euismod accumsan. </code></td>
<td nowrap>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin et enim quis arcu pharetra aliquet. Maecenas posuere tellus arcu, a suscipit dui posuere eu. Nunc vestibulum ligula sit amet eros euismod accumsan. </td>
</tr>
</table>
</div>
```

## Links

```bash
[LINK TEXT](LINK ADDRESS)
```

For example:

```bash
[The Google home page](http://www.google.co.uk)
```

You can write the link in HTML with a `target="blank"` element to make the link open in a new internet browser tab by default:

```bash
<a href="LINK ADDRESS" target="blank">LINK TEXT</a>
```

## Images

`!``[]``(LOCATION_OF_IMAGE)`
