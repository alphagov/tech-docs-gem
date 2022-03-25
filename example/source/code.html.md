---
title: Code examples
---

# Code examples

A paragraph with a `code` element within it.

<a href="#"><code>code element within a link</code></a>

An example of a table with a `code` element within it.

| httpResult | Message | How to fix |
| -          | -       | -          |
| `400`      | `[{`<br>`"error": "BadRequestError",`<br>`"message": "Can't send to this recipient using a team-only API key"`<br>`]}` | Use the correct type of API key |

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
