RSpec.describe GovukTechDocs::Pages do
  describe "#to_json" do
    it "returns the pages as JSON" do
      sitemap = double(resources: [
        double(url: "/a.html", data: double(title: "A thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "0 days")),
        double(url: "/b.html", data: double(title: "B thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "2 days")),
      ])

      json = described_class.new(sitemap, tech_docs: {}).to_json

      expect(JSON.parse(json)).to eql([
        { "title" => "A thing", "url" => "/a.html", "review_by" => Date.yesterday.to_s, "owner_slack" => "#2ndline" },
        { "title" => "B thing", "url" => "/b.html", "review_by" => Date.tomorrow.to_s, "owner_slack" => "#2ndline" },
      ])
    end
  end
end
