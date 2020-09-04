RSpec.describe GovukTechDocs::MetaTags do
  describe "#browser_title" do
    it "combines the page title and service name" do
      browser_title = generate_title(site_name: "Test Site", page_title: "The Title")

      expect(browser_title).to eql("The Title - Test Site")
    end

    it "does not duplicate the page title" do
      browser_title = generate_title(site_name: "My documentation site", page_title: "My documentation site")

      expect(browser_title).to eql("My documentation site")
    end

    it "does not show an empty page title" do
      browser_title = generate_title(site_name: "My documentation site", page_title: nil)

      expect(browser_title).to eql("My documentation site")
    end

    def generate_title(site_name:, page_title:)
      config = generate_config(
        service_name: site_name,
      )

      current_page = double("current_page",
                            data: { description: "The description.", title: page_title },
                            metadata: { locals: {} })

      GovukTechDocs::MetaTags.new(config, current_page).browser_title
    end
  end

  describe "#tags" do
    it "returns standard meta tags" do
      config = generate_config(
        host: "https://www.example.org",
        service_name: "Foo",
        full_service_name: "Test Site",
      )

      current_page = double("current_page",
                            data: { description: "The description.", title: "The Title" },
                            url: "/foo.html",
                            metadata: { locals: {} })

      tags = GovukTechDocs::MetaTags.new(config, current_page).tags

      expect(tags).to eql(
        "description" => "The description.",
        "twitter:card" => "summary",
        "twitter:domain" => "www.example.org",
        "twitter:image" => "https://www.example.org/images/govuk-large.png",
        "twitter:title" => "The Title - Test Site",
        "twitter:url" => "https://www.example.org/foo.html",
      )
    end

    it "adds a noindex robots tag when the site config prevents indexing" do
      config = generate_config(
        prevent_indexing: true,
      )

      current_page = double("current_page",
                            data: {},
                            url: "/foo.html",
                            metadata: { locals: {} })

      tags = GovukTechDocs::MetaTags.new(config, current_page).tags

      expect(tags["robots"]).to eql("noindex")
    end

    it "adds a noindex robots tag when the page frontmatter prevents indexing" do
      current_page = double("current_page",
                            data: { prevent_indexing: true },
                            url: "/foo.html",
                            metadata: { locals: {} })

      tags = GovukTechDocs::MetaTags.new(generate_config, current_page).tags

      expect(tags["robots"]).to eql("noindex")
    end

    it "adds a google site validation meta tag when provided in config" do
      config = generate_config(
        google_site_verification: "LEGIT-VALIDATION-TOKEN",
      )

      current_page = double("current_page",
                            data: {},
                            url: "/foo.html",
                            metadata: { locals: {} })

      tags = GovukTechDocs::MetaTags.new(config, current_page).tags

      expect(tags["google-site-verification"]).to eql("LEGIT-VALIDATION-TOKEN")
    end

    it "uses the local variable as page description for proxied pages" do
      current_page = double("current_page",
                            data: { description: "The description." },
                            url: "/foo.html",
                            metadata: { locals: { description: "The local variable description." } })

      tags = GovukTechDocs::MetaTags.new(generate_config, current_page).tags

      expect(tags["description"]).to eql("The local variable description.")
    end

    it "works even when no config is set" do
      current_page = double("current_page",
                            data: {},
                            url: "/foo.html",
                            metadata: { locals: { title: "The local variable title." } })

      config = { tech_docs: {} }

      tags = GovukTechDocs::MetaTags.new(config, current_page).tags

      expect(tags).to be_a(Hash)
    end
  end

  describe "#opengraph_tags" do
    it "returns opengraph meta tags" do
      config = generate_config(
        host: "https://www.example.org",
        service_name: "Foo",
        full_service_name: "Test Site",
      )

      current_page = double("current_page",
                            data: { description: "The description.", title: "The Title" },
                            url: "/foo.html",
                            metadata: { locals: {} })

      og_tags = GovukTechDocs::MetaTags.new(config, current_page).opengraph_tags

      expect(og_tags).to eql(
        "og:description" => "The description.",
        "og:image" => "https://www.example.org/images/govuk-large.png",
        "og:site_name" => "Test Site",
        "og:title" => "The Title",
        "og:type" => "object",
        "og:url" => "https://www.example.org/foo.html",
      )
    end

    it "uses the local variable as page title for proxied pages" do
      current_page = double("current_page",
                            data: { description: "The description." },
                            url: "/foo.html",
                            metadata: { locals: { title: "The local variable title." } })

      tags = GovukTechDocs::MetaTags.new(generate_config, current_page).opengraph_tags

      expect(tags["og:title"]).to eql("The local variable title.")
    end
  end

  def generate_config(config = {})
    {
      tech_docs: {
        host: "https://www.example.org",
        service_name: "Test Site",
      }.merge(config),
    }
  end
end
