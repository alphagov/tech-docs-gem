require "middleman-syntax/extension"

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

RSpec.describe "code blocks" do
  let(:app) { double("app") }
  let(:context) { double("context") }

  before :each do
    allow(context).to receive(:app) { app }
    allow(app).to receive(:api)
  end

  describe "without syntax highlighting" do
    let(:processor) {
      Redcarpet::Markdown.new(GovukTechDocs::TechDocsHTMLRenderer.new(context: context), fenced_code_blocks: true)
    }

    describe "#render" do
      it "sets tab index to 0" do
        output = processor.render <<~MARKDOWN
          Hello world:

          ```ruby
          def hello_world
            puts "hello world"
          end
          ```
        MARKDOWN

        expect(output).to include('<pre tabindex="0">')
        expect(output).to include("def hello_world")
        expect(output).to include('puts "hello world"')
        expect(output).to include("end")
      end
    end
  end

  describe "with syntax highlighting" do
    let(:processor) {
      renderer_class = GovukTechDocs::TechDocsHTMLRenderer.clone.tap do |c|
        c.send :include, Middleman::Syntax::RedcarpetCodeRenderer
      end

      Redcarpet::Markdown.new(renderer_class.new(context: context), fenced_code_blocks: true)
    }

    describe "#render" do
      it "sets tab index to 0" do
        output = processor.render <<~MARKDOWN
          Hello world:

          ```ruby
          def hello_world
            puts "hello world"
          end
          ```
        MARKDOWN

        expect(output).to include('<pre tabindex="0" class=" ruby">')
        expect(output).to include("def</span>")
        expect(output).to include("hello_world</span>")
        expect(output).to include("puts</span>")
        expect(output).to include('"hello world"</span>')
        expect(output).to include("end</span>")
      end
    end
  end
end
