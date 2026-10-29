require "rack/files"
require "capybara/rspec"
require "uri"

Capybara.app = Rack::Files.new("spec/test-site/build")

RSpec.describe "GOV.UK pagination" do
  include Capybara::DSL

  context "with the default configuration" do
    before { rebuild_site! }

    it "does not show pagination unless enabled" do
      visit "/index.html"

      expect(page).to have_no_css ".govuk-pagination"
    end

    it "allows a page to opt in through frontmatter" do
      visit "/pagination-enabled.html"

      expect(page).to have_css "nav.govuk-pagination.govuk-pagination--block[aria-label='Pagination']"
      expect(page).to have_no_css ".govuk-pagination__prev"
      expect(page).to have_css ".govuk-pagination__next a[rel='next']", text: "Pagination disabled"
    end
  end

  context "when enabled globally" do
    before { rebuild_site!(overrides: { "show_govuk_pagination" => true }) }

    it "uses the standard block component with labelled links in sidebar order" do
      visit "/nested-page/another-nested-page/index.html"
      links = sidebar_page_links
      current_index = links.index { |link| link[:label] == "Another nested page" }

      expect(current_index).not_to be_nil
      expect(page).to have_css "main nav.govuk-pagination.govuk-pagination--block[aria-label='Pagination']"
      expect(page).to have_no_css ".app-page-navigation"
      expect_pagination_link("prev", links.fetch(current_index - 1))
      expect_pagination_link("next", links.fetch(current_index + 1))
    end

    it "omits previous on the first page and next on the last page" do
      visit "/pagination-enabled.html"
      last_page_href = sidebar_page_links.last.fetch(:href)

      expect(page).to have_no_css ".govuk-pagination__prev"
      expect(page).to have_css ".govuk-pagination__next"

      last_page_path = URI.join(page.current_url, last_page_href).path
      last_page_path += "index.html" if last_page_path.end_with?("/")
      visit last_page_path

      expect(page).to have_css ".govuk-pagination__prev"
      expect(page).to have_no_css ".govuk-pagination__next"
    end

    it "allows a page to opt out without removing it from the navigation order" do
      visit "/pagination-disabled.html"
      expect(page).to have_no_css ".govuk-pagination"

      visit "/pagination-enabled.html"
      expect(page).to have_css ".govuk-pagination__next a[rel='next']", text: "Pagination disabled"
    end

    it "does not show pagination without a matching multipage sidebar" do
      %w[/single-page-nav.html /hidden-page.html /core-layout.html /core-layout-without-sidebar.html].each do |path|
        visit path
        expect(page).to have_no_css ".govuk-pagination"
      end
    end

    it "does not include hidden pages, redirects or heading anchors in pagination" do
      visit "/nested-page/index.html"

      links = sidebar_page_links
      expect(links.map { |link| link[:href] }).not_to include(a_string_matching(/hidden-page|something\/old|#/))
      expect(page).to have_no_css '.govuk-pagination a[href*="#"]'
    end
  end

  context "when disabled globally" do
    before { rebuild_site!(overrides: { "show_govuk_pagination" => false }) }

    it "lets frontmatter override the global setting" do
      visit "/pagination-enabled.html"
      expect(page).to have_css ".govuk-pagination"

      visit "/index.html"
      expect(page).to have_no_css ".govuk-pagination"
    end
  end

  context "without multipage navigation" do
    before { rebuild_site!(overrides: { "show_govuk_pagination" => true, "multipage_nav" => false }) }

    it "does not render pagination even for a page that opts in" do
      visit "/pagination-enabled.html"
      expect(page).to have_no_css ".govuk-pagination"
    end
  end

  def sidebar_page_links
    all("#toc a[href]").filter_map { |link|
      href = link[:href]
      next if href.empty? || href.include?("#")

      { href:, label: link.text.strip }
    }.uniq { |link| link[:href] }
  end

  def expect_pagination_link(direction, expected)
    link = find(".govuk-pagination a[rel='#{direction}']")
    expect(link[:href]).to eq(expected.fetch(:href))
    expect(link).to have_css ".govuk-pagination__link-label", exact_text: expected.fetch(:label)
  end
end
