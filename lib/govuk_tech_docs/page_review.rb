module GovukTechDocs
  class PageReview
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def review_by
      return unless last_reviewed_on

      @review_by ||= Chronic.parse(
        "in #{page.data.review_in}",
        now: last_reviewed_on.to_time
      ).to_date
    end

    def under_review?
      page.data.review_in.present?
    end

    def last_reviewed_on
      page.data.last_reviewed_on
    end

    def owner_slack
      page.data.owner_slack
    end

    def owner_slack_url
      # Slack URLs don't have the # (channels) or @ (usernames)
      slack_identifier = owner_slack.to_s.delete('#').delete('@')
      "https://govuk.slack.com/messages/#{slack_identifier}"
    end
  end
end
