RSpec.describe GovukTechDocs::PathHelpers do
  include GovukTechDocs::PathHelpers

  describe "#get_path_to_resource" do
    it "calculates the path to a resource when using absolute links" do
      resource_url = "/documentation/introduction/index.html"

      config = {}
      resource = double("resource", url: resource_url)

      resource_path = get_path_to_resource(config, resource, nil)
      expect(resource_path).to eql(resource_url)
    end

    it "calculates the path to a resource when using relative links" do
      current_page_path = "/documentation/introduction/section-one/index.html"
      url = "/documentation/introduction/index.html"

      config = {
        relative_links: true,
      }
      resource = double("resource", url: url, path: url)
      current_page = double("current_page", path: current_page_path)

      resource_path = get_path_to_resource(config, resource, current_page)
      expect(resource_path).to eql("../../../documentation/introduction/index.html")
    end
  end

  describe "#path_to_site_root" do
    it "calculates the path from a page to the site root when using absolute links" do
      page_path = "/documentation/introduction/index.html"

      config = {
        http_prefix: "/", # This is Middleman's default setting.
      }

      path_to_site_root = path_to_site_root(config, page_path)
      expect(path_to_site_root).to eql("/")
    end

    it "calculates the path from a page to the site root when a middleman http prefix" do
      page_path = "/bananas/documentation/introduction/index.html"

      config = {
        http_prefix: "/bananas",
      }

      path_to_site_root = path_to_site_root(config, page_path)
      expect(path_to_site_root).to eql("/bananas/")
    end

    it "calculates the path from a page to the site root when using relative links" do
      page_path = "/documentation/introduction/index.html"

      config = {
        relative_links: true,
      }

      path_to_site_root = path_to_site_root(config, page_path)
      expect(path_to_site_root).to eql("../../")
    end
  end
end
