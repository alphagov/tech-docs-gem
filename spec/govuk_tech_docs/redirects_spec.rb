require "govuk_tech_docs/doubles"

RSpec.describe GovukTechDocs::Redirects do
  describe "#redirects" do
    it "calculates redirects as a relative path from the site root" do
      config = {
        relative_links: true,
        tech_docs: {
          redirects: {
            # A page has been renamed in an existing folder
            "documentation/some-location/old-page.html" => "documentation/some-location/new-page.html",
            # A page has been moved between sibling folders
            "documentation/old-location/index.html" => "documentation/new-location/index.html",
            # A page has been moved and has changed its position in the folder hierarchy
            "documentation/some-path/old-location/index.html" => "documentation/new-location/index.html",
            # A page has been moved but within some shared common folder hierarchy
            "documentation/some-common-path/old-location/index.html" => "documentation/some-common-path/new-location/index.html",
          },
        },
      }
      context = double("Middleman::ConfigContext")
      allow(context).to receive(:config).and_return config
      allow(context).to receive_message_chain(:sitemap, :resources).and_return []

      under_test = described_class.new(context)
      redirects = under_test.redirects

      expect(redirects[0][0]).to eql("documentation/some-location/old-page.html")
      expect(redirects[0][1][:to]).to eql("../../documentation/some-location/new-page.html")

      expect(redirects[1][0]).to eql("documentation/old-location/index.html")
      expect(redirects[1][1][:to]).to eql("../../documentation/new-location/index.html")

      expect(redirects[2][0]).to eql("documentation/some-path/old-location/index.html")
      expect(redirects[2][1][:to]).to eql("../../../documentation/new-location/index.html")

      expect(redirects[3][0]).to eql("documentation/some-common-path/old-location/index.html")
      expect(redirects[3][1][:to]).to eql("../../../documentation/some-common-path/new-location/index.html")
    end

    it "performs no manipulation of redirects when the site is not using relative links" do
      old_location = "documentation/old-location/index.html"
      new_location = "documentation/new-location/index.html"
      config = {
        relative_links: false,
        tech_docs: {
          redirects: {
            old_location => new_location,
          },
        },
      }
      context = double("Middleman::ConfigContext")
      allow(context).to receive(:config).and_return config
      allow(context).to receive_message_chain(:sitemap, :resources).and_return []

      under_test = described_class.new(context)
      redirects = under_test.redirects

      expect(redirects[0][0]).to eql(old_location)
      expect(redirects[0][1][:to]).to eql(new_location)
    end
  end
end
