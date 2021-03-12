RSpec.describe GovukTechDocs::TechDocsHTMLRenderer do
  let(:app) { double("app") }
  let(:context) { double("context") }
  let(:processor) {
    allow(context).to receive(:app) { app }
    allow(app).to receive(:api)
    Redcarpet::Markdown.new(described_class.new(context: context), tables: true)
  }

  describe "#render a table" do
    markdown_table = <<~MARKDOWN
     |  A   | B |
     |------|---|
     |# C   | D |
     |  E   | F |
     |# *G* | H |
    MARKDOWN

    it "treats cells in the heading row as headings" do
      output = processor.render markdown_table

      expect(output).to include("<th>A</th>")
      expect(output).to include("<th>B</th>")
    end

    it "treats cells starting with # as row headings" do
      output = processor.render markdown_table
      expect(output).to include('<th scope="row">C</th>')
    end

    it "treats cells starting with # with more complex markup as row headings" do
      output = processor.render markdown_table
      expect(output).to match(/<th scope="row"><em>G<\/em>\s*<\/th>/)
    end

    it "treats other cells as ordinary cells" do
      output = processor.render markdown_table
      expect(output).to include("<td>D</td>")
      expect(output).to include("<td>E</td>")
      expect(output).to include("<td>F</td>")
      expect(output).to include("<td>H</td>")
    end
  end
end
