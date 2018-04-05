RSpec.describe GovukTechDocs::PageReview do
  describe '#under_review?' do
    it "is when there's a review_in date" do
      review_by = described_class.new(
        double(data: double(review_in: "6 months"))
      )

      expect(review_by.under_review?).to eql(true)
    end
  end

  describe '#owner_slack_url' do
    it "links to Slack usernames" do
      review_by = described_class.new(
        double(data: double(owner_slack: "@foo"))
      )

      expect(review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/foo")
    end

    it "links to Slack channels" do
      review_by = described_class.new(
        double(data: double(owner_slack: "#foo"))
      )

      expect(review_by.owner_slack_url).to eql("https://govuk.slack.com/messages/foo")
    end
  end

  describe '#review_by' do
    it "calculates it correctly" do
      review_by = described_class.new(
        double(data: double(last_reviewed_on: Date.parse("2016-01-01"), review_in: "6 months"))
      )

      expect(review_by.review_by).to eql(Date.parse("2016-07-01"))
    end
  end
end
