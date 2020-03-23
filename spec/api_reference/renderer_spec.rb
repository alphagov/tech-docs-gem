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
        "paths": {
          "/widgets": {
            "get": {
              "responses": {
                "200": {
                  "description": "description goes here",
                  "content": {
                    "application/json": {
                      "schema": {
                        "$ref": "#/components/schemas/widgets"
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "components": {
          "schemas": {
            "widgets": {
              "properties": {
                "data": {
                  "type": "array",
                  "items": {
                    "$ref": "#/components/schemas/widget"
                  }
                }
              }
            },
            "widget": {
              "anyOf": [
               { "$ref": "#/components/schemas/widgetInteger" },
               { "$ref": "#/components/schemas/widgetString" },
              ],
            },
            "widgetInteger": {
              "type": "object",
              "properties": {
                "id": { "type": "integer", example: 12345 }
              }
            },
            "widgetString": {
              "type": "object",
              "properties": {
                "id": { "type": "string", example: "abcde" }
              }
            }
          }
        }
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

    describe '#json_output' do
      let(:document) { Openapi3Parser.load(@spec) }

      subject { described_class.new(nil, document) }

      it 'renders first anyOf reference example' do
        schema = document.paths["/widgets"].get.node_data["responses"]["200"]["content"]["application/json"]["schema"]

        json = subject.json_output(schema)
        hash = JSON.parse(json)

        expect(hash).to eql({"data"=>[{"id"=>12345}]})
      end
    end
  end
end
