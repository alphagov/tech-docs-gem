# Insert a warning

Use the warning text component when you need to warn users about something important, such as legal consequences of an action, or lack of action, that they might take.

This warning text format is taken from the [GOV.UK Design System warning text](https://design-system.service.gov.uk/components/warning-text/).

Insert the following HTML code into your content file:

```bash
<style>
.govuk-warning-text{font-family:nta,Arial,sans-serif;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-weight:400;font-size:16px;font-size:1rem;line-height:1.25;color:#0b0c0c;position:relative;margin-bottom:20px;padding:10px 0}@media print{.govuk-warning-text{font-family:sans-serif}}@media (min-width:40.0625em){.govuk-warning-text{font-size:19px;font-size:1.1875rem;line-height:1.31579}}@media print{.govuk-warning-text{font-size:14pt;line-height:1.15;color:#000}}@media (min-width:40.0625em){.govuk-warning-text{margin-bottom:30px}}.govuk-warning-text__assistive{position:absolute!important;width:1px!important;height:1px!important;margin:-1px!important;padding:0!important;overflow:hidden!important;clip:rect(0 0 0 0)!important;-webkit-clip-path:inset(50%)!important;clip-path:inset(50%)!important;border:0!important;white-space:nowrap!important}.govuk-warning-text__icon{font-family:nta,Arial,sans-serif;-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-weight:700;display:inline-block;position:absolute;top:50%;left:0;min-width:32px;min-height:29px;margin-top:-20px;padding-top:3px;border:3px solid #0b0c0c;border-radius:50%;color:#fff;background:#0b0c0c;font-size:1.6em;line-height:29px;text-align:center;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none}@media print{.govuk-warning-text__icon{font-family:sans-serif}}.govuk-warning-text__text{display:block;margin-left:-15px;padding-left:65px}
</style>

<div class="govuk-warning-text">
<span class="govuk-warning-text__icon" aria-hidden="true">!</span>
<strong class="govuk-warning-text__text">
<span class="govuk-warning-text__assistive">Warning</span>
<p>INSERT-WARNING-TEXT-HERE</p>
</div>
```

If you have multiple warnings in one content file, you only need to insert the `<style>...</style>` text once. 

You can then insert the `<div class="govuk-warning-text">...</div>` once for each separate warning.

