RSpec.describe GovukTechDocs::PageReview do
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

    it "links to Slack usernames without the @ prefix" do
      config = { owner_slack_workspace: "govuk", default_owner_slack: "@from.config" }
      page_review_by = described_class.new(
        double(data: double(owner_slack: "@from.page")),
        tech_docs: config,
      )
      config_review_by = described_class.new(
        double(data: double(owner_slack: nil)),
        tech_docs: config,
      )

      expect(page_review_by.owner_slack).to eql("@from.page")
      expect(page_review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/from.page")
      expect(config_review_by.owner_slack).to eql("@from.config")
      expect(config_review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/from.config")
    end

    it "links to Slack channels without the # prefix" do
      config = { owner_slack_workspace: "govuk", default_owner_slack: "#from_config" }
      page_review_by = described_class.new(
        double(data: double(owner_slack: "#from_page")),
        tech_docs: config,
      )
      config_review_by = described_class.new(
        double(data: double(owner_slack: nil)),
        tech_docs: config,
      )

      expect(page_review_by.owner_slack).to eql("#from_page")
      expect(page_review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/from_page")
      expect(config_review_by.owner_slack).to eql("#from_config")
      expect(config_review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/from_config")
    end
  end

  describe "#review_by" do
    it "calculates it correctly" do
      review_by = described_class.new(
        double(data: double(last_reviewed_on: Date.parse("2016-01-01"), review_in: "6 months")),
      )

      expect(review_by.review_by).to eql(Date.parse("2016-07-01"))
    end
  end
end
