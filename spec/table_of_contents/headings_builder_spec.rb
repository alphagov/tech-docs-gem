require "spec_helper"

describe GovukTechDocs::TableOfContents::HeadingsBuilder do
  it "builds a collection of headings from HTML" do
    html = %{
      <h1 id="apples">Apples</h1>
      <p>A fruit</p>
      <h2 id="apple-recipes">Apple recipes</h2>
      <p>Get some apples..</p>
      <h1 id="pears">Pears</h1>
    }
    url = ""

    headings = described_class.new(html, url).headings

    expect(headings).to eq([
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h2", text: "Apple recipes", attributes: { "id" => "apple-recipes" }),
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Pears", attributes: { "id" => "pears" }),
    ])
  end
end
