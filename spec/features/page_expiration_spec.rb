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

  def when_the_site_is_created
    `cd example && rm -rf build && bundle install --quiet && middleman build`
  end

  def and_i_visit_an_expired_page
    visit "/expired-page.html"
  end

  def then_i_see_that_the_page_expired
    expect(page).to have_content "This page was last reviewed on 18 January 1983"
  end
end
