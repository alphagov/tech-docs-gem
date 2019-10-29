require "ostruct"

RSpec.describe GovukTechDocs::SourceUrls do
  describe "#report_issue_url" do
    it "provides a GitHub issue link by default" do
      current_page = generate_current_page("title", "url")
      config = generate_config("test/repo", "https://test-docs/")
      source_urls = GovukTechDocs::SourceUrls.new(current_page, config)

      expect(source_urls.report_issue_url).to eql("https://github.com/test/repo/issues/new?labels=bug&title=Re: 'title'&body=Problem with 'title' (https://test-docs/url)")
    end

    it "uses a custom URL when configured" do
      current_page = generate_current_page("title", "url")
      config = generate_config("test/repo", "https://test-docs/")
      config[:source_urls] = {
        report_issue_url: "mailto:test@example.com",
      }
      source_urls = GovukTechDocs::SourceUrls.new(current_page, config)

      expect(source_urls.report_issue_url).to eql("mailto:test@example.com?subject=Re: 'title'&body=Problem with 'title' (https://test-docs/url)")
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
