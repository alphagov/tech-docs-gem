require "middleman-syntax/extension"

RSpec.describe GovukTechDocs::TechDocsHTMLRenderer do
  let(:app) { double("app") }
  let(:context) { double("context") }
  let(:processor) {
    Redcarpet::Markdown.new(described_class.new(context: context), tables: true, fenced_code_blocks: true)
  }

  before :each do
    allow(context).to receive(:app) { app }
    allow(app).to receive(:api)
  end

  describe "#render a table" do
    let(:output) {
      processor.render <<~MARKDOWN
        |  A   | B |
        |------|---|
        |# C   | D |
        |  E   | F |
        |# *G* | H |
      MARKDOWN
    }

    it "treats cells in the heading row as headings" do
      expect(output).to include("<th>A</th>")
      expect(output).to include("<th>B</th>")
    end

    it "treats cells starting with # as row headings" do
      expect(output).to include('<th scope="row">C</th>')
    end

    it "treats cells starting with # with more complex markup as row headings" do
      expect(output).to match(/<th scope="row"><em>G<\/em>\s*<\/th>/)
    end

    it "treats other cells as ordinary cells" do
      expect(output).to include("<td>D</td>")
      expect(output).to include("<td>E</td>")
      expect(output).to include("<td>F</td>")
      expect(output).to include("<td>H</td>")
    end
  end

  describe "#render a code block" do
    let(:output) {
      processor.render <<~MARKDOWN
        Hello world:

        ```ruby
        def hello_world
          puts "hello world"
        end
        ```
      MARKDOWN
    }

    context "without syntax highlighting" do
      let(:processor) {
        Redcarpet::Markdown.new(described_class.new(context: context), fenced_code_blocks: true)
      }

      it "sets tab index to 0" do
        expect(output).to include('<pre tabindex="0">')
      end

      it "renders the code without syntax highlighting" do
        expect(output).to include("def hello_world")
        expect(output).to include('puts "hello world"')
        expect(output).to include("end")
      end
    end


    context "with syntax highlighting" do
      let(:processor) {
        renderer_class = described_class.clone.tap do |c|
          c.send :include, Middleman::Syntax::RedcarpetCodeRenderer
        end
        Redcarpet::Markdown.new(renderer_class.new(context: context), fenced_code_blocks: true)
      }

      it "sets tab index to 0" do
        expect(output).to include('<pre class=" ruby" tabindex="0">')
      end

      it "renders the code with syntax highlighting" do
        expect(output).to include("def</span>")
        expect(output).to include("hello_world</span>")
        expect(output).to include("puts</span>")
        expect(output).to include('"hello world"</span>')
        expect(output).to include("end</span>")
      end
    end
  end
end
