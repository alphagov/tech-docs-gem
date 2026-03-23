RSpec.describe GovukTechDocs::CustomMethodMissingHandler do
  let(:app) { double("Middleman::Application").as_null_object }
  let(:mock_renderer) { instance_spy("GovukTechDocs::GovukNunjuckComponenetRenderer") }
  let(:template_response) { "<a-gov-uk>Component</a-gov-uk>" }
  # based on # [2](https://github.com/middleman/middleman/blob/master/middleman-core/lib/middleman-core/extension.rb)

  let(:helper_context) do
    ctx = Object.new
    described_class.defined_helpers.each { |mod| ctx.extend(mod) }
    ctx
  end

  before do
    allow(GovukTechDocs::GovukNunjuckComponenetRenderer).to receive(:new).and_return(mock_renderer)
    allow(helper_context).to receive(:method_missing).and_call_original

    allow(template_response).to receive(:html_safe).and_return(template_response)
    allow(mock_renderer).to receive(:render_govuk_component).and_return(template_response)
  end

  describe "when a custom method is called the method_missing helper" do
    it "is called to see if it can be handled" do
      expect(helper_context).to receive(:method_missing)
      expect { helper_context.jam({}) }.to raise_error(NoMethodError)
    end

    RSpec::Expectations.configuration.on_potential_false_positives = :nothing
    it "recognises a method with the prefix `govuk` and doesn't throw a NoMethodError" do
      expect(helper_context).to receive(:method_missing)
      expect { helper_context.govukTest }.to_not raise_error(NoMethodError)
    end

    it "will pass along any data passed into the function call" do
      nujucks_data = { text: "Sausages taste good!" }
      expect(helper_context).to receive(:method_missing).with(any_args, nujucks_data)
      helper_context.govukTest(nujucks_data)
    end

    it "will call continue up the ruby chain and raise a NoMethodError if it doesn't recognise the prefix" do
      expect(mock_renderer).to_not receive(:render_govuk_component)
      expect { helper_context.sausageTest }.to raise_error(NoMethodError)
    end
  end

  describe "when a method with a govuk prefix is called it can" do
    it "call the govukNunjucks renderer" do
      expect(mock_renderer).to receive(:render_govuk_component)
      expect(template_response).to receive(:html_safe)
      helper_context.govukTest
    end

    it "pass any data to the govukNunjucks renderer" do
      nujucks_data = { text: "Testing is Awesome" }
      expect(mock_renderer).to receive(:render_govuk_component).with(any_args, nujucks_data)
      helper_context.govukTest(nujucks_data)
    end

    it "return the html string from the govukNunjucks renderer " do
      expect(mock_renderer).to receive(:render_govuk_component).and_return(template_response)
      result = helper_context.govukTest
      expect(result).to eq(template_response)
    end

    it "can handle errors that come from the govukNunjucks renderer" do
      allow(mock_renderer).to receive(:render_govuk_component).and_raise("Template Error")
      expect { helper_context.govukJamFlavours({ text: "Jam is better than sausages" }) }.to raise_error(RuntimeError, "Template Error")
    end
  end
end
