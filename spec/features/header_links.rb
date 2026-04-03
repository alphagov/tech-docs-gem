require "rack/files"
require "capybara/rspec"

# want to be able to test directory indexes without the .html extension
Capybara.app = Rack::Builder.new do
  use Rack::Static, urls: [""], root: "example/build", index: "index.html"
  run Rack::Files.new("example/build")
end

#   Documentation: /
#   Expired page: /expired-page.html
#   Expired with owner: /expired-page-with-owner.html
#   Not expired page: /not-expired-page.html
#   Single page nav: /single-page-nav.html
#   Active pages: /active-pages/

describe "Active header links " do
  include Capybara::DSL

  describe "are not visible on " do
    it "the homepage when there are none provided to the config" do
      given_the_site_is_created_without_links_in_the_config
      when_i_visit_the_url_provided "/"
      when_the_page_has_finished_loading
      then_no_navigation_links_are_present
      then_no_active_link_class_is_present
    end

    it "nested pages when there are none provided to the config" do
      given_the_site_is_created_without_links_in_the_config
      when_i_visit_the_url_provided "/nested-page/another-nested-page/"
      when_the_page_has_finished_loading
      then_no_navigation_links_are_present
      then_no_active_link_class_is_present
    end

    it "full urls when there are none provided to the config" do
      given_the_site_is_created_without_links_in_the_config
      when_i_visit_the_url_provided "/expired-page-with-owner.html"
      when_the_page_has_finished_loading
      then_no_navigation_links_are_present
      then_no_active_link_class_is_present
    end
  end

  describe "are visible" do
    it "when header_links are present in the config" do
      given_the_site_is_created_with_links_in_the_config
      when_i_visit_the_url_provided "/"
      when_the_page_has_finished_loading
      then_the_header_links_in_the_config_are_visible
    end

    describe "are active on " do
      it "the homepage only when visiting the home page" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_only_the_expected_header_link_is_active "Documentation"
      end

      it "the expected link when the header_link is a specific .html page" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/expired-page.html"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_only_the_expected_header_link_is_active "Expired page"
      end

      it "the expected link when the page has a parent specified that is a header_link" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/child-of-expired-page.html"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_only_the_expected_header_link_is_active "Expired page"
      end

      it "the expected link when the page is the root of a nested folder section" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/active-pages/"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_the_page_should_have_the_expected_content "This is a section landing page, under the “Active pages” navigation link."
        then_only_the_expected_header_link_is_active "Active pages"
      end

      it "the expected link when the page is a child of a nested folder section" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/active-pages/sub-section/"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_the_page_should_have_the_expected_content "This is a section sub section, under the “Active pages” navigation link."
        then_only_the_expected_header_link_is_active "Active pages"
      end
    end

    describe "are not active on" do
      it "a page that has no header link or parent associated with it" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/api-path.html"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_no_active_link_class_is_present
      end

      it "a nested page that has no header link or parent associated with it" do
        given_the_site_is_created_with_links_in_the_config
        when_i_visit_the_url_provided "/nested-page/another-nested-nested-page/"
        when_the_page_has_finished_loading
        then_the_header_links_in_the_config_are_visible
        then_no_active_link_class_is_present
      end
    end
  end

  def given_the_site_is_created_without_links_in_the_config
    rebuild_site! overrides: { "header_links" => {} }
  end

  def then_only_the_expected_header_link_is_active(link_text)
    active_links = all(
      ".govuk-header__navigation-item.govuk-header__navigation-item--active",
    )
    expect(active_links.length).to eq(1)
    expect(active_links[0].text).to eq(link_text)
  end

  def given_the_site_is_created_with_links_in_the_config
    rebuild_site!
  end

  def when_i_visit_the_url_provided(page_path)
    visit page_path
  end

  def when_the_page_has_finished_loading
    assert_text("My First Service") # tech_docs_config["service_name"]
  end

  def then_the_page_should_have_the_expected_content(content_string)
    assert_text(content_string)
  end

  def then_no_navigation_links_are_present
    expect(page).not_to have_css("li.govuk-header__navigation-item")
  end

  def then_no_active_link_class_is_present
    expect(page).not_to have_css("li.govuk-header__navigation-item--active")
  end

  def then_the_header_links_in_the_config_are_visible
    tech_docs_config["header_links"].each do |link_text, path|
      link = page.find(
        "li.govuk-header__navigation-item a.govuk-header__link",
        exact_text: link_text,
      )
      expect(link[:href]).to eq(path)
    end
  end
end
