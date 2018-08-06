require 'rack/file'
require 'capybara/rspec'

Capybara.app = Rack::File.new("example/build")

RSpec.describe "The tech docs template" do
  include Capybara::DSL

  it "generates a working static site" do
    when_the_site_is_created
    and_i_visit_the_homepage
    then_there_is_a_heading
    then_there_is_a_search_form
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

    when_i_view_an_api_reference_page
    then_there_is_correct_api_info_content
    then_there_is_correct_api_path_content
    then_there_is_correct_api_schema_content

    when_i_view_an_single_path_api_reference_page
    then_there_is_correct_api_path_content
  end

  def when_the_site_is_created
    puts `cd example && rm -rf build && bundle install && middleman build --verbose`
  end

  def and_i_visit_the_homepage
    visit '/index.html'
  end

  def then_there_is_a_heading
    expect(page).to have_css 'h1', text: 'Hello, World!'
  end

  def then_there_is_a_search_form
    expect(page).to have_css 'input#search'
  end

  def and_there_are_proper_meta_tags
    expect(page).to have_title 'GOV.UK Documentation Example | My First Service'
    expect(page).to have_css 'meta[property="og:site_name"]', visible: false
  end

  def then_there_is_a_source_footer
    %w[
      https://github.com/alphagov/example-repo/blob/master/source/index.html.md.erb
      https://github.com/alphagov/example-repo
    ].each do |url|
      expect(page).to have_link(nil, href: url)
    end
  end

  def then_the_page_highlighted_in_the_navigation_is(link_label)
    page.find('#navigation li.active a', text: link_label)
  end

  def then_there_are_navigation_headings_from_other_pages
    expect(page).to have_css '.toc__list a', text: 'A subheader'
  end

  def when_i_view_a_proxied_page
    visit '/a-proxied-page.html'
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
    visit '/something/old.html'
    expect(page.body).to match '<link rel="canonical" href="/" />'
  end

  def and_frontmatter_redirects_are_working
    visit '/something/old-as-well.html'
    expect(page.body).to match '<link rel="canonical" href="/" />'
  end

  def when_i_view_expired_page
    visit '/expired-page.html'
  end

  def when_i_view_child_of_expired_page
    visit '/child-of-expired-page.html'
  end

  def when_i_view_the_search_index
    visit '/search.json'
  end

  def when_i_view_an_api_reference_page
    visit '/api-reference.html'
  end

  def then_there_is_indexed_content
    expect(page).to have_content 'troubleshoot'
  end

  def when_i_view_an_single_path_api_reference_page
    visit '/api-path.html'
  end

  def then_there_is_correct_api_info_content
    # Title
    expect(page).to have_css('h1', text: 'Swagger Petstore v1.0.0')
    # Description
    expect(page).to have_css('p', text: 'A sample API that uses a petstore as an example to demonstrate features in the OpenAPI 3.0 specification')
    # Base URL
    expect(page).to have_css('strong', text: 'http://petstore.swagger.io/v1')
  end

  def then_there_is_correct_api_path_content
    # Path title
    expect(page).to have_css('h2#get-pets', text: 'GET /pets')
    # Path parameters
    expect(page).to have_css('table', text: /\b(How many items to return at one time)\b/)
    # Link to schema
    expect(page).to have_css('table a[href="#schema-error"]')
  end

  def then_there_is_correct_api_schema_content
    # Schema title
    expect(page).to have_css('h3#schema-pet', text: 'Pet')
    # Schema parameters
    expect(page).to have_css('table', text: /\b(tag )\b/)
  end
end
