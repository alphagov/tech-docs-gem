require "rack/file"
require "capybara/rspec"

Capybara.app = Rack::File.new("example/build")

RSpec.describe "Diagrams in code blocks" do
  include Capybara::DSL

  it "generates static SVG from mermaid code blocks" do
    when_the_site_is_created
    and_i_visit_the_code_page
    then_there_is_an_svg_diagram
  end

  def when_the_site_is_created
    rebuild_site!
  end

  def and_i_visit_the_code_page
    visit "/code.html"
  end

  def then_there_is_an_svg_diagram
    expect(page.body).to match '<svg id="mermaid-'
  end
end
