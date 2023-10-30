require "govuk_tech_docs/doubles"

RSpec.describe GovukTechDocs::PathHelpers do
  include GovukTechDocs::PathHelpers

  describe "#get_path_to_resource" do
    context "calculate paths for internal resources" do
      resource_url = "/documentation/introduction/index.html"

      it "when the site is configured to generate absolute links" do
        config = {}

        resource = create_resource_double(url: resource_url)
        resource_path = get_path_to_resource(config, resource, nil)

        expect(resource_path).to eql(resource_url)
      end

      it "when the site is configured to generate relative links" do
        config = {
          relative_links: true,
        }

        current_page_path = "/documentation/introduction/section-one/index.html"
        current_page = create_resource_double(url: current_page_path, path: current_page_path)
        resource = create_resource_double(url: resource_url, path: resource_url)
        resource_path = get_path_to_resource(config, resource, current_page)

        expect(resource_path).to eql("../../../documentation/introduction/index.html")
      end
    end

    context "calculate paths for internal page paths (which are represented as strings)" do
      current_page_path = "/documentation/introduction/section-one/index.html"

      it "when the site is configured to generate absolute links" do
        config = {}

        url = "/documentation/introduction/index.html"
        current_page = double("current_page", path: current_page_path)
        resource_path = get_path_to_resource(config, url, current_page)

        expect(resource_path).to eql(url)
      end

      it "when the site is configured to generate relative links" do
        config = {
          relative_links: true,
        }

        url = "/documentation/introduction/index.html"
        current_page = create_resource_double(url: current_page_path, path: current_page_path)
        resource_path = get_path_to_resource(config, url, current_page)

        expect(resource_path).to eql("../../../documentation/introduction/index.html")
      end
    end

    context "calculate URLs for external URLs" do
      external_urls = [
        "https://www.example.com/some-page.html", # With scheme included.
        "www.example.com/some-page.html", # With scheme omitted.
      ]
      external_urls.each do |external_url|
        current_page_path = "/documentation/introduction/section-one/index.html"

        it "when the site is configured to generate absolute links" do
          config = {}

          current_page = double("current_page", path: current_page_path)
          resource_path = get_path_to_resource(config, external_url, current_page)

          expect(resource_path).to eql(external_url)
        end

        it "when the site is configured to generate relative links" do
          config = {
            relative_links: true,
          }

          current_page = double("current_page", path: current_page_path)
          resource_path = get_path_to_resource(config, external_url, current_page)

          expect(resource_path).to eql(external_url)
        end
      end
    end
  end

  describe "#path_to_site_root" do
    it "calculates the path from a page to the site root when the site is configured to generate absolute links" do
      config = {
        http_prefix: "/", # This is Middleman's default setting.
      }

      page_path = "/documentation/introduction/index.html"
      path_to_site_root = path_to_site_root(config, page_path)

      expect(path_to_site_root).to eql("/")
    end

    it "calculates the path from a page to the site root when a middleman http prefix" do
      config = {
        http_prefix: "/bananas",
      }

      page_path = "/bananas/documentation/introduction/index.html"
      path_to_site_root = path_to_site_root(config, page_path)

      expect(path_to_site_root).to eql("/bananas/")
    end

    it "calculates the path from a page to the site root when the site is configured to generate relative links" do
      config = {
        relative_links: true,
      }

      page_path = "/documentation/introduction/index.html"
      path_to_site_root = path_to_site_root(config, page_path)

      expect(path_to_site_root).to eql("../../")
    end
  end
end
