## Contributing to this project

Everybody who uses this project is encouraged to contribute to this project. If you're part of the [alphagov GitHub organisation](https://www.github.com/alphagov) you probably have write access to this repo. If you don't, ask a GitHub admin or #tech-docs-format on Slack.

- Before adding your feature, [check the backlog to see if someone is already talking about it](https://github.com/alphagov/tech-docs-template/issues)
- If you add a new option to `config/tech-docs.yml`, make sure you [document the new configuration option][configuration]
- If you add a new option to the page frontmatter, make sure you [document the new frontmatter configuration](docs/frontmatter.md)
- You can test your contribution using [unit tests](spec/govuk_tech_docs), [javascript tests](spec/javascripts) or [integration tests](spec/features)
- If your change is relevant to the users of the gem, add something to [CHANGELOG](CHANGELOG.md). You don't have to do this if it's just refactoring. Make sure that you include any upgrade instructions.

[configuration]: https://github.com/alphagov/tdt-documentation/blob/master/source/amend_project/configuration/index.html.md.erb
[frontmatter]: https://github.com/alphagov/tdt-documentation/blob/master/source/frontmatter.html.md.erb
