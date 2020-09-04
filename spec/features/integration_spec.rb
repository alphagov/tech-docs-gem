require "rack/file"
require "capybara/rspec"

Capybara.app = Rack::File.new("example/build")

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
end
