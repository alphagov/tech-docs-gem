module GovukTechDocs
  class WarningTextExtension < Middleman::Extension
    def initialize(app, options_hash = {}, &block)
      super
    end

    helpers do
      def warning_text(text)
        warn("The `warning_text` function will be removed in version 7. You should use the GOV.UK warning text component instead.")
        <<~EOS
        <div class="govuk-warning-text">
          <span class="govuk-warning-text__icon" aria-hidden="true">!</span>
          <strong class="govuk-warning-text__text">
            <span class="govuk-visually-hidden">Warning</span>
            #{text}
          </strong>
        </div>
        EOS
      end
    end
  end
end

::Middleman::Extensions.register(:warning_text, GovukTechDocs::WarningTextExtension)
