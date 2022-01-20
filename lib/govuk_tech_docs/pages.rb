module GovukTechDocs
  class Pages
    include GovukTechDocs::PathHelpers
    attr_reader :sitemap

    def initialize(sitemap, config, current_page)
      @sitemap = sitemap
      @config = config
      @current_page = current_page
    end

    def to_json(*_args)
      as_json.to_json
    end

  private

    def as_json
      pages.map do |page|
        review = PageReview.new(page, @config)
        {
          title: page.data.title,
          url: get_path_to_resource(@config, page, @current_page).to_s,
          review_by: review.review_by,
          owner_slack: review.owner_slack,
        }
      end
    end

    def pages
      sitemap.resources.select { |page| page.data.title }
    end
  end
end
