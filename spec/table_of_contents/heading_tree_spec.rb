require "spec_helper"

describe GovukTechDocs::TableOfContents::HeadingTree do
  describe "#==" do
    it "is true if the trees have the same headings for every node" do
      a = GovukTechDocs::TableOfContents::HeadingTree.new(
        children: [
          GovukTechDocs::TableOfContents::HeadingTree.new(
            heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
            children: [
              GovukTechDocs::TableOfContents::HeadingTree.new(
                heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h2", text: "Seeds", attributes: { "id" => "seeds" }),
              ),
            ],
          ),
        ],
      )
      b = GovukTechDocs::TableOfContents::HeadingTree.new(
        children: [
          GovukTechDocs::TableOfContents::HeadingTree.new(
            heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
            children: [
              GovukTechDocs::TableOfContents::HeadingTree.new(
                heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h2", text: "Seeds", attributes: { "id" => "seeds" }),
              ),
            ],
          ),
        ],
      )

      expect(a).to eq(b)
    end

    it "is false if the number of leaves of the tree differ" do
      a = GovukTechDocs::TableOfContents::HeadingTree.new(
        children: [
          GovukTechDocs::TableOfContents::HeadingTree.new(
            heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
          ),
          GovukTechDocs::TableOfContents::HeadingTree.new(
            heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Oranges", attributes: { "id" => "oranges" }),
          ),
        ],
      )
      b = GovukTechDocs::TableOfContents::HeadingTree.new(
        children: [
          GovukTechDocs::TableOfContents::HeadingTree.new(
            heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
          ),
        ],
      )

      expect(a).to_not eq(b)
    end

    it "is false if a heading differs" do
      a = GovukTechDocs::TableOfContents::HeadingTree.new(
        heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Apples", attributes: { "id" => "apples" }),
      )
      b = GovukTechDocs::TableOfContents::HeadingTree.new(
        heading: GovukTechDocs::TableOfContents::Heading.new(element_name: "h1", text: "Oranges", attributes: { "id" => "oranges" }),
      )

      expect(a).to_not eq(b)
    end
  end
end
