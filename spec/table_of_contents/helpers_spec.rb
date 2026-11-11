require "spec_helper"

describe GovukTechDocs::TableOfContents::Helpers do
  describe "#select_top_level_html_files" do
    subject(:helpers) { Class.new { include GovukTechDocs::TableOfContents::Helpers }.new }

    it "preserves the default root when called without configuration" do
      parent = double("root", url: "/")
      page = double("page", path: "guide.html", parent:)

      expect(helpers.select_top_level_html_files([page])).to eq([page])
    end

    [nil, {}, { http_prefix: nil }, { http_prefix: "" }, { http_prefix: "/" }].each do |config|
      it "uses the default root with configuration #{config.inspect}" do
        page = double("page", path: "guide.html", parent: double("root", url: "/"))

        expect(helpers.select_top_level_html_files([page], config)).to eq([page])
      end
    end

    ["/docs", "/docs/", "/service/docs", "/service/docs/", "\\"].each do |prefix|
      it "selects only top-level HTML pages under #{prefix.inspect}" do
        root_url = prefix.end_with?("/") ? prefix : "#{prefix}/"
        root = double("root", url: root_url)
        page = double("page", path: "guide.html", parent: root, url: "#{root_url}guide.html")
        orphan = double("orphan", path: "index.html", parent: nil)
        child = double("child", path: "guide/child.html", parent: page)
        asset = double("asset", path: "logo.svg", parent: root)

        expect(helpers.select_top_level_html_files([page, orphan, child, asset], { http_prefix: prefix })).to eq([page, orphan])
      end
    end
  end

  describe "#single_page_table_of_contents" do
    subject do
      subject_class = Class.new do
        include GovukTechDocs::TableOfContents::Helpers
      end
      subject_class.new
    end

    it "builds a table of contents from html" do
      html = %(
        <h1 id="fruit">Fruit</h1>
        <h1 id="apples">Apples</h1>
        <p>A fruit</p>
        <h2 id="apple-recipes">Apple recipes</h2>
        <p>Get some apples..</p>
      )

      expected_single_page_table_of_contents = %(
<ul>
  <li>
    <a href="#fruit"><span>Fruit</span></a>
  </li>
  <li>
    <a href="#apples"><span>Apples</span></a>
    <ul>
      <li>
        <a href="#apple-recipes"><span>Apple recipes</span></a>
      </li>
    </ul>
  </li>
</ul>
      )

      expect(subject.single_page_table_of_contents(html).strip).to eq(expected_single_page_table_of_contents.strip)
    end

    it "builds a table of contents from html when headings suddenly change by more than one size" do
      html = %(
        <h1 id="fruit">Fruit</h1>
        <h3 id="apples">Apples</h3>
        <p>A fruit</p>
        <h4 id="apple-recipes">Apple recipes</h4>
        <p>Get some apples..</p>
        <h1 id="bread">Bread</h1>
      )

      expected_single_page_table_of_contents = %(
<ul>
  <li>
    <a href="#fruit"><span>Fruit</span></a>
    <ul>
      <li>
        <ul>
          <li>
            <a href="#apples"><span>Apples</span></a>
            <ul>
              <li>
                <a href="#apple-recipes"><span>Apple recipes</span></a>
              </li>
            </ul>
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    <a href="#bread"><span>Bread</span></a>
  </li>
</ul>
      )

      expect(subject.single_page_table_of_contents(html).strip).to eq(expected_single_page_table_of_contents.strip)
    end

    it "builds a table of contents from HTML without an h1" do
      html = %(
        <h2 id="apples">Apples</h3>
      )

      expect { subject.single_page_table_of_contents(html).strip }.to raise_error(RuntimeError)
    end
  end

  describe "#multi_page_table_of_contents" do
    subject do
      subject_class = Class.new do
        include GovukTechDocs::TableOfContents::Helpers
      end
      subject_class.new
    end

    before do
      stub_const(
        "FakeData",
        Class.new do
          attr_reader :weight, :title, :hide_in_navigation

          def initialize(weight = nil, title = nil)
            @weight = weight
            @title = title
          end
        end,
      )

      stub_const(
        "FakeResource",
        Class.new do
          attr_reader :url, :data, :parent, :children, :path

          def initialize(url, html, weight = nil, title = nil, parent = nil, children = [], path: nil)
            @url = url
            @html = html
            @parent = parent
            @children = children
            @data = FakeData.new(weight, title)
            @path = path || url
          end

          def render(_layout)
            @html
          end

          def add_children(children)
            @children.concat children
          end

          def is_a?(klass)
            klass.to_s == "Middleman::Sitemap::Resource"
          end
        end,
      )
    end

    ["/", "/docs", "/docs/", "/service/docs", "/service/docs/"].each do |prefix|
      it "renders top-level pages and nested children once with http_prefix #{prefix.inspect}" do
        root_url = prefix.end_with?("/") ? prefix : "#{prefix}/"
        home = FakeResource.new(root_url, '<h1 id="home">Home</h1>', 0, "Home", path: "index.html")
        guide = FakeResource.new("#{root_url}guide/", '<h1 id="guide">Guide</h1>', 1, "Guide", home, path: "guide/index.html")
        child = FakeResource.new("#{root_url}guide/child/", '<h1 id="child">Child</h1>', 2, "Child", guide, path: "guide/child/index.html")
        home.add_children([guide])
        guide.add_children([child])
        config = { http_prefix: prefix, tech_docs: { max_toc_heading_level: 3 } }

        output = Nokogiri::HTML.fragment(subject.multi_page_table_of_contents([home, guide, child], home, config))

        expect(output.xpath("./ul/li/a").map { |link| link["href"] }).to eq([root_url, "#{root_url}guide/"])
        expect(output.css("a").map { |link| link["href"] }).to eq([root_url, "#{root_url}guide/", "#{root_url}guide/child/"])
      end
    end

    it "builds a table of contents using absolute links from several page resources" do
      resources = []
      resources[0] = FakeResource.new("/index.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 10, "Index")
      resources[1] = FakeResource.new("/1/2/a.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 20, "Sub page A", resources[0])
      resources[2] = FakeResource.new("/1/2/3/b.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 30, "Sub page A", resources[0])
      resources[3] = FakeResource.new("/1/2/3/4/c.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 40, "Sub page B", resources[0])
      resources[4] = FakeResource.new("/1/5/d.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 50, "Sub page A", resources[0])
      resources[5] = FakeResource.new("/1/5/6/e.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 60, "Sub page A", resources[0])
      resources[0].add_children [resources[1], resources[2], resources[3], resources[4], resources[5]]

      current_page = double("current_page",
                            data: double("page_frontmatter", description: "The description.", title: "The Title"),
                            url: "/1/2/3/index.html",
                            path: "/1/2/3/index.html",
                            metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>'

      config = {
        http_prefix: "/",
        tech_docs: {
          max_toc_heading_level: 3,
        },
      }

      expected_multi_page_table_of_contents = %(
<ul>
<li><a href="/index.html"><span>Index</span></a>
<ul>
  <li>
    <a href="/1/2/a.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/1/2/a.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/1/2/3/b.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/1/2/3/b.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/1/2/3/4/c.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/1/2/3/4/c.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/1/5/d.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/1/5/d.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/1/5/6/e.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/1/5/6/e.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
</ul>
</li>
</ul>
      )

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end

    it "builds a table of contents using relative links from several page resources" do
      resources = []
      resources[0] = FakeResource.new("/index.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 10, "Index")
      resources[1] = FakeResource.new("/1/2/a.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 20, "Sub page A", resources[0])
      resources[2] = FakeResource.new("/1/2/3/b.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 30, "Sub page A", resources[0])
      resources[3] = FakeResource.new("/1/2/3/4/c.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 40, "Sub page B", resources[0])
      resources[4] = FakeResource.new("/1/5/d.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 50, "Sub page A", resources[0])
      resources[5] = FakeResource.new("/1/5/6/e.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 60, "Sub page A", resources[0])
      resources[0].add_children [resources[1], resources[2], resources[3], resources[4], resources[5]]

      current_page = double("current_page",
                            data: double("page_frontmatter", description: "The description.", title: "The Title"),
                            url: "/1/2/3/index.html",
                            path: "/1/2/3/index.html",
                            metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>'

      config = {
        http_prefix: "/",
        relative_links: true,
        tech_docs: {
          max_toc_heading_level: 3,
        },
      }

      expected_multi_page_table_of_contents = %(
<ul>
<li><a href="../../../index.html"><span>Index</span></a>
<ul>
  <li>
    <a href="../../../1/2/a.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="../../../1/2/a.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="../../../1/2/3/b.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="../../../1/2/3/b.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="../../../1/2/3/4/c.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="../../../1/2/3/4/c.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="../../../1/5/d.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="../../../1/5/d.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="../../../1/5/6/e.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="../../../1/5/6/e.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
</ul>
</li>
</ul>
      )

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end

    it "builds a table of contents from several page resources with a custom http prefix configured" do
      resources = []
      resources[0] = FakeResource.new("/prefix/index.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 10, "Index")
      resources[1] = FakeResource.new("/prefix/a.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 10, "Sub page A", resources[0])
      resources[2] = FakeResource.new("/prefix/b.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>', 20, "Sub page B", resources[0])
      resources[0].add_children [resources[1], resources[2]]

      current_page = double("current_page",
                            data: double("page_frontmatter", description: "The description.", title: "The Title"),
                            url: "/prefix/index.html",
                            path: "/prefix/index.html",
                            metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>'

      config = {
        http_prefix: "/prefix",
        tech_docs: {
          max_toc_heading_level: 3,
        },
      }

      expected_multi_page_table_of_contents = %(
<ul>
<li><a href="/prefix/index.html"><span>Index</span></a>
<ul>
  <li>
    <a href="/prefix/a.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/prefix/a.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/prefix/b.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/prefix/b.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
</ul>
</li>
</ul>
      )

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end

    it "builds a table of contents from a single page resources" do
      resources = []
      resources.push FakeResource.new("/index.html", '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>')

      current_page = double("current_page",
                            data: double("page_frontmatter", description: "The description.", title: "The Title"),
                            url: "/index.html",
                            path: "/index.html",
                            metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2><h1 id="heading-one">Heading one</h1><h2 id="heading-two">Heading two</h2>'

      config = {
        http_prefix: "/",
        tech_docs: {
          max_toc_heading_level: 3,
          multipage_nav: true,
        },
      }

      expected_multi_page_table_of_contents = %(
<ul>
  <li>
    <a href="/index.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/index.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/index.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/index.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
  <li>
    <a href="/index.html"><span>Heading one</span></a>
    <ul>
      <li>
        <a href="/index.html#heading-two"><span>Heading two</span></a>
      </li>
    </ul>
  </li>
</ul>
      )

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html).strip).to eq(expected_multi_page_table_of_contents.strip)
    end

    it "builds a table of contents from a single page resource when include_child_resources is set to false" do
      resources = []
      resources[0] = FakeResource.new("/index.html", '<h1 id="heading-one">Parent heading one</h1><h2 id="heading-two">Parent heading two</h2>', 10, "Index")
      resources[1] = FakeResource.new("/1/2/a.html", '<h1 id="heading-one">Child heading one</h1><h2 id="heading-two">Child heading two</h2>', 20, "Sub page A", resources[0])
      resources[2] = FakeResource.new("/1/2/3/b.html", '<h1 id="heading-one">Second child heading one</h1><h2 id="heading-two">Second child heading two</h2>', 30, "Sub page A", resources[0])

      resources[0].add_children [resources[1], resources[2]]

      current_page = double("current_page",
                            data: double("page_frontmatter", description: "The description.", title: "The Title"),
                            url: "/index.html",
                            path: "/index.html",
                            metadata: { locals: {} })

      current_page_html = '<h1 id="heading-one">Parent heading one</h1><h2 id="heading-two">Parent heading two</h2>'

      config = {
        http_prefix: "/",
        tech_docs: {
          max_toc_heading_level: 3,
          multipage_nav: true,
        },
      }

      expected_multi_page_table_of_contents = %(
<ul>
  <li>
    <a href="/index.html"><span>Parent heading one</span></a>
    <ul>
      <li>
        <a href="/index.html#heading-two"><span>Parent heading two</span></a>
      </li>
    </ul>
  </li>
</ul>
      )

      expect(subject.multi_page_table_of_contents(resources, current_page, config, current_page_html, include_child_resources: false).strip).to eq(expected_multi_page_table_of_contents.strip)
    end
  end
end
