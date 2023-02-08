require "uri"
module GovukTechDocs
  module PathHelpers
    # Some useful notes from https://www.rubydoc.info/github/middleman/middleman/Middleman/Sitemap/Resource#url-instance_method :
    # 'resource.path' is "The source path of this resource (relative to the source directory, without template extensions)."
    # 'resource.destination_path', which is: "The output path in the build directory for this resource."
    # 'resource.url' is based on 'resource.destination_path', but is further tweaked to optionally strip the index file and prefixed with any :http_prefix.

    # Calculates the path to the sought resource, taking in to account whether the site has been configured
    # to generate relative or absolute links.
    # Identifies whether the sought resource is an internal or external target: External targets are returned untouched. Path calculation is performed for internal targets.
    # Works for both "Middleman::Sitemap::Resource" resources and plain strings (which may be passed from the site configuration when generating header links).
    #
    # @param [Object] config
    # @param [Object] resource
    # @param [Object] current_page
    def get_path_to_resource(config, resource, current_page)
      if resource.is_a?(Middleman::Sitemap::Resource)
        config[:relative_links] ? get_resource_path_relative_to_current_page(config, current_page.path, resource.path) : resource.url
      elsif external_url?(resource)
        resource
      elsif config[:relative_links]
        get_resource_path_relative_to_current_page(config, current_page.path, resource)
      else
        resource
      end
    end

    def path_to_site_root(config, page_path)
      if config[:relative_links]
        number_of_ascents_to_site_root = page_path.to_s.split("/").reject(&:empty?)[0..-2].length
        ascents = number_of_ascents_to_site_root.zero? ? ["."] : number_of_ascents_to_site_root.times.collect { ".." }
        path_to_site_root = ascents.join("/").concat("/")
      else
        middleman_http_prefix = config[:http_prefix]
        path_to_site_root = middleman_http_prefix.end_with?("/") ? middleman_http_prefix : "#{middleman_http_prefix}/"
      end
      path_to_site_root
    end

  private

    # Calculates the path to the sought resource, relative to the current page.
    # @param [Object] config Middleman config.
    # @param [String] current_page path of the current page, from the site root.
    # @param [String] resource_path_from_site_root path of the sought resource, from the site root.
    def get_resource_path_relative_to_current_page(config, current_page, resource_path_from_site_root)
      path_segments = resource_path_from_site_root.split("/").reject(&:empty?)[0..-2]
      path_file_name = resource_path_from_site_root.split("/")[-1]

      path_to_site_root = path_to_site_root config, current_page
      path_to_site_root + path_segments.push(path_file_name).join("/")
    end

    def external_url?(url)
      uri = URI.parse(url)
      uri.scheme || uri.to_s.split("/")[0]&.include?(".")
    end
  end
end
