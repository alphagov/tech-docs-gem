RSpec.describe GovukTechDocs::TechDocsHTMLRenderer do
  describe "#render a table" do
    it "renders tables with row headings" do
      app = double("app")
      context = double("context")
      allow(context).to receive(:app) { app }
      allow(app).to receive(:api)

      processor = Redcarpet::Markdown.new(described_class.new(context: context), tables: true)
      output = processor.render <<~MARKDOWN
       |  A   | B |
       |------|---|
       |# C   | D |
       |  E   | F |
       |# *G* | H |
      MARKDOWN

      # Cells in the heading row should be treated as headings
      expect(output).to include("<th>A</th>")
      expect(output).to include("<th>B</th>")

      # Cells starting with `#` should be treated as row headings
      expect(output).to include('<th scope="row">C</th>')

      # Cells starting with `#` with more complex markup should be treated as row headings
      expect(output).to match(/<th scope="row"><em>G<\/em>\s*<\/th>/)

      # Other cells should be treated as ordinary cells
      expect(output).to include("<td>D</td>")
      expect(output).to include("<td>E</td>")
      expect(output).to include("<td>F</td>")
      expect(output).to include("<td>H</td>")
    end
  end
end
