require "spec_helper"

describe GovukTechDocs::TableOfContents::HeadingTreeBuilder do
  it "creates a tree of headings depending on their size" do
    headings = [
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h3", text: "Apple recipes", attributes: { "id" => "apple-recipes" }),
      GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Oranges", attributes: { "id" => "oranges" }),
    ]

    expected_tree = GovukTechDocs::TableOfContents::HeadingTree.new(
      children: [
        GovukTechDocs::TableOfContents::HeadingTree.new(
          heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
          children: [
            GovukTechDocs::TableOfContents::HeadingTree.new(
              children: [
                GovukTechDocs::TableOfContents::HeadingTree.new(
                  heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h3", text: "Apple recipes", attributes: { "id" => "apple-recipes" }),
                ),
              ],
            ),
          ],
        ),
        GovukTechDocs::TableOfContents::HeadingTree.new(
          heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Oranges", attributes: { "id" => "oranges" }),
        ),
      ],
    )

    expect(described_class.new(headings).tree).to eq(expected_tree)
  end
end
