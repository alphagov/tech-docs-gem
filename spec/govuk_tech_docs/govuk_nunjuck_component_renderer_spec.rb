RSpec.describe GovukTechDocs::GovukNunjuckComponenetRenderer do
  let(:gem_root) { "/mock/gem/path" }
  subject { described_class.new(gem_root) }

  describe "get_component_template_name is passed a govuk component name it" do
    it "removes the govuk prefix" do
      expect(subject.get_component_template_name("govukJamFlavours")).to_not include "govuk"
    end

    it "converts the first letter of the component name to lower case" do
      expect(subject.get_component_template_name("govukButton")).to eq("button")
    end

    it "splits up component names with more than one word, sets both words to lower case and adds a hyphen" do
      expect(subject.get_component_template_name("govukNotificationBanner")).to eq("notification-banner")
    end

    it "handles unlikely weird acronyms correctly" do
      expect(subject.get_component_template_name("govukJSONData")).to eq("json-data")
    end
  end

  describe "#render_govuk_component" do
    let(:component_name) { "govukButton" }
    let(:data) { { text: "Save" } }

    it "builds the correct Nunjucks macro string and calls the JS method" do
      # We mock the Schmooze 'method' call to avoid needing real Node/Nunjucks
      expect(subject).to receive(:render_nunjucks_template).with(
        include("import govukButton"), # Verifies the Macro import line
        { "templateData" => data },    # Verifies the data wrap
        instance_of(Array), # Verifies search paths are passed
      ).and_return("<button>Success</button>")

      result = subject.render_govuk_component(component_name, data)
      expect(result).to eq("<button>Success</button>")
    end

    context "when the JS rendering throws an error" do
      it "rescues the error and returns an empty safe string" do
        # Force the Schmooze-defined method to explode
        error_message = "Computer says NO!!!!!"
        allow(subject).to receive(:render_nunjucks_template).and_raise(StandardError, error_message)
        expect { subject.render_govuk_component(component_name, data) }.to raise_error(RuntimeError, error_message)
      end
    end
  end
end
