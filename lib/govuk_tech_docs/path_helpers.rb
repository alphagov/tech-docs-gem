module GovukTechDocs
  module PathHelpers
    def get_path_to_resource(config, resource, current_page)
      if config[:relative_links]
        resource_path_segments = resource.path.split("/").reject(&:empty?)[0..-2]
        resource_file_name = resource.path.split("/")[-1]

        path_to_site_root = path_to_site_root config, current_page.path
        resource_path = path_to_site_root + resource_path_segments
                                           .push(resource_file_name)
                                           .join("/")
      else
        resource_path = resource.url
      end
      resource_path
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
  end
end
