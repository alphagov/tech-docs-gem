---
title: Code examples
---

# Code examples

A paragraph with a `code` element within it.

<a href="#"><code>code element within a link</code></a>

An example of a table with a `code` element within it.

<div class="table-container">
  <table>
    <thead>
      <tr>
        <th style="text-align:left">httpResult</th>
        <th style="text-align:left">Message</th>
        <th style="text-align:left">How to fix</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td style="text-align:left"><code>400</code></td>
        <td style="text-align:left">
          <code>[{</code>
          <br />
          <code>"error": "BadRequestError",</code>
          <br />
          <code>"message": "Can't send to this recipient using a team-only API key"</code>
          <br />
          <code>]}</code>
        </td>
        <td style="text-align:left">Use the correct type of API key</td>
      </tr>
    </tbody>
  </table>
</div>

An example of a code block with a long line length

```ruby
RSpec.describe ContentItem do
  subject { described_class.new(base_path) }
  let(:base_path) { "/search/news-and-communications" }
  let(:finder_content_item) { news_and_communications }
  let(:news_and_communications) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "news_and_communications.json")))
  }

  RSpec.describe "as_hash" do
    it "returns a content item as a hash" do
      expect(subject.as_hash).to eql(finder_content_item)
    end
  end
end
```

An example of a code block with a short length

```ruby
RSpec.describe ContentItem do
end
```
