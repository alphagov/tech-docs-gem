require 'rack/file'
require 'capybara/rspec'

Capybara.app = Rack::File.new("example/build")

RSpec.describe "The tech docs template" do
  include Capybara::DSL

  it "generates a working static site" do
    when_the_site_is_created
    and_i_visit_the_homepage
    then_there_is_a_heading
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
end
