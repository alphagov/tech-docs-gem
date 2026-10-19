RSpec.describe GovukTechDocs::PageReview do
  describe "#last_reviewed_on" do
    it "preserves dates loaded from unquoted YAML" do
      date = Date.new(2026, 1, 1)
      review = described_class.new(double(data: double(last_reviewed_on: date)))

      expect(review.last_reviewed_on).to equal(date)
    end

    it "accepts a quoted ISO date from YAML frontmatter" do
      data = YAML.safe_load('last_reviewed_on: "2024-02-29"')
      review = described_class.new(double(data: double(last_reviewed_on: data.fetch("last_reviewed_on"))))

      expect(review.last_reviewed_on).to eql(Date.new(2024, 2, 29))
    end

    it "preserves a missing date" do
      review = described_class.new(double(data: double(last_reviewed_on: nil)))

      expect(review.last_reviewed_on).to be_nil
    end

    ["2023-02-29", "2026-13-01", "01/02/2026", "2026/01/01", "2026-01-01 extra", ""].each do |date|
      it "rejects invalid or ambiguous date #{date.inspect}" do
        review = described_class.new(double(data: double(last_reviewed_on: date)))

        expect { review.last_reviewed_on }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#under_review?" do
    it "is when there's a review_in date" do
      review_by = described_class.new(
        double(data: double(review_in: "6 months")),
        tech_docs: { owner_slack_workspace: "govuk" },
      )

      expect(review_by.under_review?).to eql(true)
    end
  end

  describe "#owner_slack_url" do
    it "is blank when no workspace is configured" do
      review_by = described_class.new(
        double(data: double(owner_slack: "@foo")),
        tech_docs: {},
      )

      expect(review_by.owner_slack_url).to be_empty
    end

    it "links to Slack usernames" do
      review_by = described_class.new(
        double(data: double(owner_slack: "@foo")),
        tech_docs: { owner_slack_workspace: "govuk" },
      )

      expect(review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/foo")
    end

    it "links to Slack channels" do
      review_by = described_class.new(
        double(data: double(owner_slack: "#foo")),
        tech_docs: { owner_slack_workspace: "govuk" },
      )

      expect(review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/foo")
    end
  end

  describe "#review_by" do
    it "calculates the deadline from a quoted ISO date" do
      review = described_class.new(
        double(data: double(last_reviewed_on: "2016-01-01", review_in: "6 months")),
      )

      expect(review.review_by).to eql(Date.new(2016, 7, 1))
    end

    it "calculates it correctly" do
      review_by = described_class.new(
        double(data: double(last_reviewed_on: Date.parse("2016-01-01"), review_in: "6 months")),
      )

      expect(review_by.review_by).to eql(Date.parse("2016-07-01"))
    end
  end
end
