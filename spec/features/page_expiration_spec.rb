require 'rack/file'
require 'capybara/rspec'

Capybara.app = Rack::File.new("example/build")

RSpec.describe "Page expiration" do
  include Capybara::DSL

  it "shows the expiration date on the page" do
    when_the_site_is_created
    and_i_visit_an_expired_page
    then_i_see_that_the_page_expired
  end

  it "hides the expiration date on the page when show_expiry is false" do
    when_the_site_is_created_hiding_expiry
    and_i_visit_an_expired_page
    then_i_dont_see_the_page_has_expired
    and_i_visit_a_not_expired_page
    then_i_dont_see_review_date
  end

  def when_the_site_is_created
    rebuild_site!
  end

  def when_the_site_is_created_hiding_expiry
    rebuild_site!(overrides: { 'show_expiry' => false })
  end

  def and_i_visit_an_expired_page
    visit "/expired-page.html"
  end

  def and_i_visit_a_not_expired_page
    visit "/not-expired-page.html"
  end

  def then_i_see_that_the_page_expired
    expect(page).to have_content "This page was last reviewed on 18 January 1983"
  end

  def then_i_dont_see_the_page_has_expired
    expect(page).to have_no_content "This might mean the content is out of date"
  end

  def then_i_dont_see_review_date
    expect(page).to have_no_content "It needs to be reviewed again on"
  end
end
