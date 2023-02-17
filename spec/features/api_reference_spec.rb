require "rack/file"
require "capybara/rspec"

Capybara.app = Rack::File.new("example/build")

RSpec.describe "OpenAPI reference" do
  include Capybara::DSL

  it "generates the api reference" do
    when_the_site_is_created
    when_i_view_an_api_reference_page
    then_there_is_correct_api_info_content
    then_there_is_correct_api_path_content
    then_there_is_correct_api_schema_content

    when_i_view_a_single_path_api_reference_page
    then_there_is_correct_api_path_content

    when_i_view_a_single_operation_api_reference_page
    then_there_is_correct_api_operation_content
    then_there_is_correct_api_schema_content
    then_there_is_not_extra_api_operation_content

    when_i_view_an_api_schema_reference_page
    then_there_is_correct_api_schema_content
    then_there_is_not_api_info_content
    then_there_is_not_api_path_content
  end

  def when_the_site_is_created
    rebuild_site!
  end

  def when_i_view_an_api_reference_page
    visit "/api-reference.html"
  end

  def when_i_view_a_single_path_api_reference_page
    visit "/api-path.html"
  end

  def when_i_view_a_single_operation_api_reference_page
    visit "/api-operation.html"
  end

  def when_i_view_an_api_schema_reference_page
    visit "/api-schema.html"
  end

  def then_there_is_correct_api_info_content
    # Title
    expect(page).to have_css("h1", text: "Swagger Petstore v1.0.0")
    # Description
    expect(page).to have_css("p", text: "A sample API that uses a petstore as an example to demonstrate features in the OpenAPI 3.0 specification")
    # Servers
    expect(page).to have_css("h2#servers", text: "Servers")
    expect(page).to have_css("a", text: "http://petstore.swagger.io/v1")
  end

  def then_there_is_correct_api_path_content
    # Path title
    expect(page).to have_css("h2#pets", text: "/pets")
    # Operation title
    expect(page).to have_css("h3#pets-get", text: "get")
    # Path parameters
    expect(page).to have_css("table", text: /\b(How many items to return at one time)\b/)
    # Link to schema
    expect(page).to have_css('table a[href="#schema-error"]')
  end

  def then_there_is_correct_api_schema_content
    # Schema title
    expect(page).to have_css("h3#schema-pet", text: "Pet")
    # Schema parameters
    expect(page).to have_css("table", text: /\b(tag )\b/)
    # Check that the "required" column is true for the `id` attribute
    expect(page).to have_css("table.schema-pet td:nth(3)", text: "true")
  end

  def then_there_is_correct_api_operation_content
    # Operation title
    expect(page).to have_css("h3#pets-get", text: "get")
    # Path parameters
    expect(page).to have_css("table", text: /\b(How many items to return at one time)\b/)
    # Link to schema
    expect(page).to have_css('table a[href="#schema-error"]')
  end

  def then_there_is_not_extra_api_operation_content
    # Path title
    expect(page).not_to have_css("h2#pets", text: "/pets")
    # Operation title
    expect(page).not_to have_css("h3#pets-post", text: "post")
  end

  alias_method :then_there_is_not_api_path_content, :then_there_is_not_extra_api_operation_content

  def then_there_is_not_api_info_content
    # Title
    expect(page).not_to have_css("h1", text: "Swagger Petstore v1.0.0")
    # Description
    expect(page).not_to have_css("p", text: "A sample API that uses a petstore as an example to demonstrate features in the OpenAPI 3.0 specification")
    # Servers
    expect(page).not_to have_css("h2#servers", text: "Servers")
    expect(page).not_to have_css("a", text: "http://petstore.swagger.io/v1")
  end
end
