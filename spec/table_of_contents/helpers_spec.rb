require 'spec_helper'

describe GovukTechDocs::TableOfContents::Helpers do
  describe '#single_page_table_of_contents' do
    class Subject
      include GovukTechDocs::TableOfContents::Helpers
    end

    subject { Subject.new }

    it 'builds a table of contents from html' do
      html = %{
        <h1 id="fruit">Fruit</h1>
        <h1 id="apples">Apples</h1>
        <p>A fruit</p>
        <h2 id="apple-recipes">Apple recipes</h2>
        <p>Get some apples..</p>
      }

      expected_single_page_table_of_contents = %{
<ul>
  <li>
    <a href="#fruit">Fruit</a>
  </li>
  <li>
    <a href="#apples">Apples</a>
    <ul>
      <li>
        <a href="#apple-recipes">Apple recipes</a>
      </li>
    </ul>
  </li>
</ul>
      }

      expect(subject.single_page_table_of_contents(html).strip).to eq(expected_single_page_table_of_contents.strip)
    end

    it 'builds a table of contents from html when headings suddenly change by more than one size' do
      html = %{
        <h1 id="fruit">Fruit</h1>
        <h3 id="apples">Apples</h3>
        <p>A fruit</p>
        <h4 id="apple-recipes">Apple recipes</h4>
        <p>Get some apples..</p>
        <h1 id="bread">Bread</h1>
      }

      expected_single_page_table_of_contents = %{
<ul>
  <li>
    <a href="#fruit">Fruit</a>
    <ul>
      <li>
        <ul>
          <li>
            <a href="#apples">Apples</a>
            <ul>
              <li>
                <a href="#apple-recipes">Apple recipes</a>
              </li>
            </ul>
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    <a href="#bread">Bread</a>
  </li>
</ul>
      }

      expect(subject.single_page_table_of_contents(html).strip).to eq(expected_single_page_table_of_contents.strip)
    end

    it 'builds a table of contents from HTML without an h1' do
      html = %{
        <h2 id="apples">Apples</h3>
      }

      expect { subject.single_page_table_of_contents(html).strip }.to raise_error(RuntimeError)
    end
  end

  describe '#multi_page_table_of_contents' do
    class Subject
      include GovukTechDocs::TableOfContents::Helpers
    end

    class FakeResource
      attr_reader :url
      def initialize(url, html)
        @url = url
        @html = html
      end

      def render(_layout)
        @html
      end
    end

    subject { Subject.new }

    it 'builds a table of contents from several page resources' do
      resources = []
      resources.push FakeResource.new('/index.html', '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>');
      resources.push FakeResource.new('/a.html', '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>');
      resources.push FakeResource.new('/b.html', '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>');

      current_page = double("current_page",
        data: double("page_frontmatter", description: "The description.", title: "The Title"),
        url: "/index.html",
        metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>';

      config = {
        tech_docs: {
          max_toc_heading_level: 3
        }
      }

      expected_multi_page_table_of_contents = %{
<ul>
  <li>
    <a href="/index.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/index.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
</ul>
<ul>
  <li>
    <a href="/a.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/a.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
</ul>
<ul>
  <li>
    <a href="/b.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/b.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
</ul>
      }

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end

    it 'builds a table of contents from a single page resources' do
      resources = []
      resources.push FakeResource.new('/index.html', '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>');

      current_page = double("current_page",
        data: double("page_frontmatter", description: "The description.", title: "The Title"),
        url: "/index.html",
        metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>';

      config = {
        tech_docs: {
          max_toc_heading_level: 3
        }
      }

      expected_multi_page_table_of_contents = %{
<ul>
  <li>
    <a href="/index.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/index.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/index.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/index.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/index.html#heading-one">Heading one</a>
    <ul>
      <li>
        <a href="/index.html#heading-two">Heading two</a>
      </li>
    </ul>
  </li>
</ul>
      }

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end
  end
end
