require "ostruct"

RSpec.describe GovukTechDocs::SourceUrls do
  describe "#report_issue_url" do
    it "provides a GitHub issue link by default" do
      current_page = generate_current_page("title", "url")
      config = generate_config("test/repo", "https://test-docs/")
      source_urls = GovukTechDocs::SourceUrls.new(current_page, config)

      expect(source_urls.report_issue_url).to eql("https://github.com/test/repo/issues/new?body=Problem+with+%27title%27+%28https%3A%2F%2Ftest-docs%2Furl%29&labels=bug&title=Re%3A+%27title%27")
    end

    it "uses a custom URL when configured" do
      current_page = generate_current_page("title", "url")
      config = generate_config("test/repo", "https://test-docs/")
      config[:source_urls] = {
        report_issue_url: "mailto:test@example.com",
      }
      source_urls = GovukTechDocs::SourceUrls.new(current_page, config)

      expect(source_urls.report_issue_url).to eql("mailto:test@example.com?body=Problem+with+%27title%27+%28https%3A%2F%2Ftest-docs%2Furl%29&subject=Re%3A+%27title%27")
    end
  end

  def generate_config(repo, host)
    {
      tech_docs: {
        host: host,
        github_repo: repo,
      },
    }
  end

  def generate_current_page(title, url)
    OpenStruct.new(
      data: OpenStruct.new(title: title),
      url: url,
    )
  end
end
