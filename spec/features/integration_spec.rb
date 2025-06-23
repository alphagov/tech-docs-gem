require "rack/files"
require "capybara/rspec"

Capybara.app = Rack::Files.new("example/build")

RSpec.describe "The tech docs template" do
  include Capybara::DSL

  it "generates a working static site" do
    when_the_site_is_created
    and_i_visit_the_homepage
    then_there_is_a_heading
    then_there_is_a_search_form
    then_there_is_a_sidebar
    then_there_is_a_source_footer
    then_the_page_highlighted_in_the_navigation_is("Documentation")
    then_there_are_navigation_headings_from_other_pages

    and_there_are_proper_meta_tags
    and_redirects_are_working
    and_frontmatter_redirects_are_working

    when_i_view_a_proxied_page
    then_there_is_another_source_footer

    when_i_view_expired_page
    then_the_page_highlighted_in_the_navigation_is("Expired page")

    when_i_view_child_of_expired_page
    then_the_page_highlighted_in_the_navigation_is("Expired page")

    when_i_view_the_search_index
    then_there_is_indexed_content

    when_i_view_a_page_with_no_sidebar
    then_there_is_no_sidebar

    when_i_view_a_page_with_prevent_indexing
    then_there_is_a_robots_noindex_metatag
  end

  # Based on the example config having show_govuk_logo set to true
  it "uses the GOV.UK brand refresh if the GOV.UK logo is used" do
    when_the_site_is_created
    and_i_visit_the_homepage
    then_the_brand_refresh_is_enabled
  end

  def when_the_site_is_created
    rebuild_site!
  end

  def and_i_visit_the_homepage
    visit "/index.html"
  end

  def then_there_is_a_heading
    expect(page).to have_css "h1", text: "Hello, World!"
  end

  def then_there_is_a_search_form
    expect(page).to have_css "input#search"
  end

  def then_there_is_a_sidebar
    expect(page).to have_css "div.app-pane__toc"
  end

  def and_there_are_proper_meta_tags
    expect(page).to have_title "GOV.UK Documentation Example - My First Service"
    expect(page).to have_css 'meta[name="description"]', visible: false
    expect(page).to have_css 'meta[property="og:site_name"]', visible: false
  end

  def then_there_is_a_source_footer
    %w[
      https://github.com/alphagov/example-repo/blob/source/source/index.html.md.erb
      https://github.com/alphagov/example-repo
    ].each do |url|
      expect(page).to have_link(nil, href: url)
    end
  end

  def then_the_page_highlighted_in_the_navigation_is(link_label)
    page.find("#navigation li.govuk-header__navigation-item--active a", text: link_label)
  end

  def then_there_are_navigation_headings_from_other_pages
    expect(page).to have_css ".toc__list a span", text: "A subheader"
  end

  def when_i_view_a_proxied_page
    visit "/a-proxied-page.html"
  end

  def then_there_is_another_source_footer
    %w[
      http://example.org/source.md
      https://github.com/alphagov/example-repo
    ].each do |url|
      expect(page).to have_link(nil, href: url)
    end
  end

  def and_redirects_are_working
    visit "/something/old.html"
    expect(page.body).to match '<link rel="canonical" href="/" />'
  end

  def and_frontmatter_redirects_are_working
    visit "/something/old-as-well.html"
    expect(page.body).to match '<link rel="canonical" href="/" />'
  end

  def when_i_view_expired_page
    visit "/expired-page.html"
  end

  def when_i_view_child_of_expired_page
    visit "/child-of-expired-page.html"
  end

  def when_i_view_the_search_index
    visit "/search.json"
  end

  def then_there_is_indexed_content
    expect(page).to have_content "troubleshoot"
  end

  def when_i_view_a_page_with_no_sidebar
    visit "/core-layout-without-sidebar.html"
  end

  def then_there_is_no_sidebar
    expect(page).to have_no_css "div.app-pane__toc"
  end

  def when_i_view_a_page_with_prevent_indexing
    visit "/prevent-index-page.html"
  end

  def then_there_is_a_robots_noindex_metatag
    expect(page).to have_css 'meta[name="robots"][content="noindex"]', visible: false
  end

  def then_the_brand_refresh_is_enabled
    # Check for class in header
    expect(page).to have_css ".govuk-template--rebranded"
    # Check for new header logo
    expect(page).to have_css ".govuk-logo-dot"
    # Check for crown svg in footer
    expect(page).to have_css ".govuk-footer__crown"
    # Check for favicons and other meta tags
    # <link rel="icon" sizes="48x48" href="<%= path_prefix %>assets/govuk/assets/rebrand/images/favicon.ico">
    expect(page).to have_css 'link[rel="icon"][sizes="48x48"][href$="assets/govuk/assets/rebrand/images/favicon.ico"]', visible: false
    # <link rel="icon" sizes="any" href="<%= path_prefix %>assets/govuk/assets/rebrand/images/favicon.svg" type="image/svg+xml">
    expect(page).to have_css 'link[rel="icon"][sizes="any"][type="image/svg+xml"][href$="assets/govuk/assets/rebrand/images/favicon.svg"]', visible: false
    # <link rel="mask-icon" href="<%= path_prefix %>assets/govuk/assets/rebrand/images/govuk-icon-mask.svg" color="#0b0c0c">
    expect(page).to have_css 'link[rel="mask-icon"][href$="assets/govuk/assets/rebrand/images/govuk-icon-mask.svg"][color="#0b0c0c"]', visible: false
    # <link rel="apple-touch-icon" href="<%= path_prefix %>assets/govuk/assets/rebrand/images/govuk-icon-180.png">
    expect(page).to have_css 'link[rel="apple-touch-icon"][href$="assets/govuk/assets/rebrand/images/govuk-icon-180.png"]', visible: false
    # <link rel="manifest" href="<%= path_prefix %>assets/govuk/assets/rebrand/manifest.json">
    expect(page).to have_css 'link[rel="manifest"][href$="assets/govuk/assets/rebrand/manifest.json"]', visible: false
  end
end
