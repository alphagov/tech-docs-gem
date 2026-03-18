RSpec.describe GovukTechDocs::CustomMethodMissingHandler do
  let(:app) { double('Middleman::Application').as_null_object }
  let(:extension) { GovukTechDocs::CustomMethodMissingHandler.new(app) }
  let(:mock_renderer) { double('GovukTechDocs::GovukNunjuckComponenetRenderer') }

  before do
    extension.instance_variable_set(:@renderer, mock_renderer)
    # @govuk_button_html = 
  end

  describe "when a custom method is called it" do

    it "will call the method_missing override to see if it can be handled" do
      expect(extension).to receive(:method_missing)
      extension.sausageTest()
    end
    
    it "will recognise a method with the prefix govuk and handle it" do
      expect(extension).to receive(:method_missing)
      extension.govukTest()
    end
    
    it "will recognise pass along any data passed into the function call" do
      nujucks_data = { text: "Sausages taste good!" }
      expect(extension).to receive(:method_missing).with(any_args,nujucks_data)
      extension.govukTest(nujucks_data)
    end
    
    it "will call continue up the ruby chain and raise an exception if it doesn't recognise it" do
      expect(mock_renderer).to_not receive(:render_govuk_component)
      expect { extension.sausageTest() }.to raise_error(NoMethodError)
    end

  end 

  describe "when a method with a govuk prefix is called it" do  

    it "can intecept the method_missing error and call the govukNunjucks renderer" do
      expect(mock_renderer).to receive(:render_govuk_component)
      extension.govukTest()
    end

    it "can pass any data to the govukNunjucks renderer" do
      nujucks_data = { text: "Testing is Awesome" }
      expect(mock_renderer).to receive(:render_govuk_component).with(any_args,nujucks_data)
      extension.govukTest(nujucks_data)
    end
 
    it "can return the html string from the govukNunjucks renderer " do
      expect(mock_renderer).to receive(:render_govuk_component).and_return("<html>")      
      result = extension.govukTest()
      expect(result).to eq("<html>")
    end

    it "can handle errors that come from the govukNunjucks renderer" do
        allow(mock_renderer).to receive(:render_govuk_component).and_raise("Template Error")
        expect {extension.govukJamFlavours({ text: "Jam is better than sausages" })}.to raise_error(RuntimeError, "Template Error")

    end

  end

end

