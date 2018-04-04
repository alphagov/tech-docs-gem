require 'rack/file'
require 'capybara/rspec'

Capybara.app = Rack::File.new("example/build")

RSpec.describe "The tech docs template" do
  include Capybara::DSL

  it "generates a working static site" do
    when_the_site_is_created
    and_i_visit_the_homepage
    then_there_is_a_heading
    then_there_is_a_source_footer

    when_i_view_a_proxied_page
    then_there_is_another_source_footer
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

  def then_there_is_a_source_footer
    %w[
      https://github.com/alphagov/example-repo/blob/master/source/index.html.md.erb
      https://github.com/alphagov/example-repo
    ].each do |url|
      expect(page).to have_link(nil, href: url)
    end
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
end
