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

  describe "#render unique heading IDs" do
    # Reset the UniqueIdentifierGenerator between each tests to ensure independence
    before(:each) { GovukTechDocs::UniqueIdentifierGenerator.instance.reset }

    it "Automatically assigns an ID to the heading" do
      output = processor.render <<~MARKDOWN
        # A heading
        ## A subheading
      MARKDOWN

      expect(output).to include('<h1 id="a-heading">A heading</h1>')
      expect(output).to include('<h2 id="a-subheading">A subheading</h2>')
    end

    it "Ensures IDs are unique among headings in the page" do
      output = processor.render <<~MARKDOWN
        # A heading
        ## A subheading
        ### A shared heading
        ### A shared heading
        ### A shared heading
        ## Another subheading
        ### A shared heading
      MARKDOWN

      # Fist heading will get its ID as a normal heading
      expect(output).to include('<h3 id="a-shared-heading">A shared heading</h3>')
      # Second occurence will be prefixed by the previous heading to ensure uniqueness
      expect(output).to include('<h3 id="a-subheading-a-shared-heading">A shared heading</h3>')
      # Third occurence will be get the prefix, as well as a numeric suffix, to keep ensuring uniqueness
      expect(output).to include('<h3 id="a-subheading-a-shared-heading-2">A shared heading</h3>')
      # Finally the last occurence will get a prefix, but no number as it's in a different section
      expect(output).to include('<h3 id="another-subheading-a-shared-heading">A shared heading</h3>')
    end

    it "Does not consider unique IDs across multiple renders" do
      processor.render <<~MARKDOWN
        # A heading
        ## A subheading
      MARKDOWN

      second_output = processor.render <<~MARKDOWN
        # A heading
        ## A subheading
      MARKDOWN

      expect(second_output).to include('<h2 id="a-subheading">A subheading</h2>')
    end
  end
end
