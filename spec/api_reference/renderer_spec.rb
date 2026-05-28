require "json"
require "capybara/rspec"
require "govuk_tech_docs/api_reference/api_reference_renderer"

RSpec.describe GovukTechDocs::ApiReference::Renderer do
  before(:each) do
    @spec = {
      "openapi": "3.0.0",
      "info": {
        "title": "title",
        "version": "0.0.1",
        "description": "# This is a header\n\nAnd a piece of _text_",
      },
      "paths": {},
      "components": { "schemas": {} },
    }
    @app = double("Middleman::Application")
    @config_context = double("Middleman::ConfigContext")
    allow(@app).to receive(:config_context).and_return @config_context
    allow(@config_context).to receive(:app).and_return @app
    allow(@app).to receive(:api) { |arg| arg }
  end

  describe ".api_full" do

    it "renders the description" do
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).to have_css("h1", exact_text: "This is a header")
      expect(rendered).to have_css("h1#this-is-a-header")
      expect(rendered).to have_css("p", exact_text: "And a piece of text")
      expect(rendered).to have_css("p>em", exact_text: "text")
    end

    it "renders no servers" do
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
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

      render = described_class.new(@app, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).not_to have_css("div#server-list>p")
    end

    it "renders a list of servers" do
      @spec["servers"] = [
        { "url": "https://example.com", "description": "Production" },
        { "url": "https://dev.example.com", "description": "_Development_" },
      ]
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = render.api_full(document.info, document.servers)

      rendered = Capybara::Node::Simple.new(rendered)
      expect(rendered).to have_css("h2#servers")
      expect(rendered).to have_css("div#server-list>a", text: "https://example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Production")
      expect(rendered).to have_css("div#server-list>a", text: "https://dev.example.com")
      expect(rendered).to have_css("div#server-list>p>strong", text: "Development")
      expect(rendered).to have_css("div#server-list>p>strong>p>em", text: "Development")
    end
  end

  describe "response content types" do
    it "renders a response with no content" do
      @spec[:paths] = {
        "/things": {
          "post": {
            "summary": "Create a thing",
            "responses": {
              "201": { "description": "Created" },
            },
          },
        },
      }
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      expect { render.api_full(document.info, document.servers) }.not_to raise_error
    end

    it "renders a JSON response body from schema" do
      @spec[:components] = { "schemas": { "Thing": { "properties": { "id": { "type": "integer" } } } } }
      @spec[:paths] = {
        "/things": {
          "get": {
            "summary": "Get things",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "application/json": { "schema": { "$ref": "#/components/schemas/Thing" } },
                },
              },
            },
          },
        },
      }
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = Capybara::Node::Simple.new(render.api_full(document.info, document.servers))

      expect(rendered).to have_css("em", text: "application/json")
      expect(rendered).to have_css("pre code", text: /"id"/)
    end

    it "renders multiple content types" do
      @spec[:components] = { "schemas": { "Thing": { "properties": { "id": { "type": "integer" } } } } }
      @spec[:paths] = {
        "/things": {
          "get": {
            "summary": "Get things",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "application/json": { "schema": { "$ref": "#/components/schemas/Thing" } },
                  "text/plain": { "schema": { "type": "string" }, "example": "hello" },
                },
              },
            },
          },
        },
      }
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = Capybara::Node::Simple.new(render.api_full(document.info, document.servers))

      expect(rendered).to have_css("em", text: "application/json")
      expect(rendered).to have_css("pre code", text: /"id"/)
      expect(rendered).to have_css("em", text: "text/plain")
      expect(rendered).to have_css("pre code", text: "hello")
    end

    it "renders non-JSON example as plain text" do
      @spec[:paths] = {
        "/things": {
          "get": {
            "summary": "Get things",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "text/plain": { "schema": { "type": "string" }, "example": "plain text response" },
                },
              },
            },
          },
        },
      }
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = Capybara::Node::Simple.new(render.api_full(document.info, document.servers))

      expect(rendered).to have_css("em", text: "text/plain")
      expect(rendered).to have_css("pre code", text: "plain text response")
    end

    it "does not render non-JSON content without an example" do
      @spec[:paths] = {
        "/things": {
          "get": {
            "summary": "Get things",
            "responses": {
              "200": {
                "description": "OK",
                "content": {
                  "application/octet-stream": { "schema": { "type": "string", "format": "binary" } },
                },
              },
            },
          },
        },
      }
      document = Openapi3Parser.load(@spec)

      render = described_class.new(@app, document)
      rendered = Capybara::Node::Simple.new(render.api_full(document.info, document.servers))

      expect(rendered).not_to have_css("pre code")
    end
  end
end
