require "json"
require "capybara/rspec"
require "govuk_tech_docs/api_reference/api_reference_renderer"


RSpec.describe GovukTechDocs::ApiReference::Renderer do
  describe ".api_full" do
    before(:each) do
      @spec = {
        "openapi": "3.0.0",
        "info": {
          "title": "title",
          "version": "0.0.1",
        },
        "paths": {},
      }
    end

    it "renders no servers" do
      document = Openapi3Parser.load(@spec)

      render = described_class.new(nil, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).not_to have_css("h2#servers")
      expect(rendered).not_to have_css("div#server-list")
    end

    it "renders a server with no description" do
      @spec["servers"] = [
        { "url": "https://example.com" },
      ]
      document = Openapi3Parser.load(@spec)

      render = described_class.new(nil, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).not_to have_css("div#server-list>p")
    end

    it "renders a list of servers" do
      @spec["servers"] = [
        { "url": "https://example.com", "description": "Production" },
        { "url": "https://dev.example.com", "description": "Development" },
      ]
      document = Openapi3Parser.load(@spec)

      render = described_class.new(nil, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Production")
      expect(rendered).to have_css("div#server-list>a", text: "https://dev.example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Development")
    end
  end
end
