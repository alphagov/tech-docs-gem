RSpec.describe GovukTechDocs::Pages do
  describe "#to_json" do
    it "returns the pages as JSON when using absolute links" do
      current_page = double(path: "/api/pages.json")
      sitemap = double(resources: [
        double(url: "/a.html", data: double(title: "A thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "0 days")),
        double(url: "/b.html", data: double(title: "B thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "2 days")),
      ])

      json = described_class.new(sitemap, {}, current_page).to_json

      expect(JSON.parse(json)).to eql([
        { "title" => "A thing", "url" => "/a.html", "review_by" => Date.yesterday.to_s, "owner_slack" => "#2ndline" },
        { "title" => "B thing", "url" => "/b.html", "review_by" => Date.tomorrow.to_s, "owner_slack" => "#2ndline" },
      ])
    end

    it "returns the pages as JSON when using relative links" do
      current_page = double(path: "/api/pages.json")
      sitemap = double(resources: [
        double(url: "/a.html", path: "/a.html", data: double(title: "A thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "0 days")),
        double(url: "/b/c.html", path: "/b/c.html", data: double(title: "B thing", owner_slack: "#2ndline", last_reviewed_on: Date.yesterday, review_in: "2 days")),
      ])

      json = described_class.new(sitemap, { relative_links: true }, current_page).to_json

      expect(JSON.parse(json)).to eql([
        { "title" => "A thing", "url" => "../a.html", "review_by" => Date.yesterday.to_s, "owner_slack" => "#2ndline" },
        { "title" => "B thing", "url" => "../b/c.html", "review_by" => Date.tomorrow.to_s, "owner_slack" => "#2ndline" },
      ])
    end
  end
end
