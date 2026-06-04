# spec/tasks/helpers/vale_report_spec.rb

require_relative "../../../lib/tasks/helpers/linter_report"
require_relative "../../../lib/tasks/helpers/vale_report"
require "json"

RSpec.describe ValeLinterReport do
  let(:valid_json) do
    {
      "file1.md" => [
        {
          "Line" => 1,
          "Severity" => "error",
          "Message" => "Bad thing",
          "Check" => "Style.Rule"
        },
        {
          "Line" => 2,
          "Severity" => "warning",
          "Message" => "Less bad thing",
          "Check" => "Style.Rule"
        }
      ],
      "file2.md" => [
        {
          "Line" => 3,
          "Severity" => "suggestion",
          "Message" => "Suggestion here",
          "Check" => "Style.Rule"
        }
      ]
    }.to_json
  end

  subject(:report) { described_class.new(raw_output) }

  describe "#format_linter_output" do
    context "with empty input" do
      let(:raw_output) { "   " }

      it "sets empty rows and zero totals" do
        report.format_linter_output

        expect(report.table_rows).to eq([])
        expect(report.linter_severity_totals).to eq(
          "error" => 0,
          "warning" => 0,
          "suggestion" => 0
        )
      end
    end

    context "with valid input" do
      let(:raw_output) { valid_json }

      before { report.format_linter_output }

      it "parses rows correctly" do
        expect(report.table_rows.size).to eq(3)
      end

      it "calculates severity totals" do
        expect(report.linter_severity_totals).to eq(
          "error" => 1,
          "warning" => 1,
          "suggestion" => 1
        )
      end

      it "generates summary JSON" do
        json = JSON.parse(report.linter_summary_report_json)

        expect(json).to eq(
          "error" => 1,
          "warning" => 1,
          "suggestion" => 1
        )
      end

      it "generates summary report string" do
        summary = report.linter_summary_report.join("\n")

        expect(summary).to include("Vale summary")
        expect(summary).to include("Errors:")
        expect(summary).to include("Warnings:")
        expect(summary).to include("Suggestions:")
      end

      it "generates full report output" do
        full = report.linter_full_report.join("\n")

        expect(full).to include("Vale Style Linting Report")
        expect(full).to include("file1.md")
        expect(full).to include("file2.md")
      end
    end
  end

  describe "JSON parsing" do
    let(:raw_output) { "invalid json" }

    it "exits on parse error" do
      report = described_class.new(raw_output)

      expect {
        report.send(:set_table_rows)
      }.to raise_error(SystemExit)
    end
  end

  describe "deduplication logic" do
    let(:raw_output) do
      {
        "file1.md" => [
          {
            "Line" => 1,
            "Severity" => "warning",
            "Message" => "Duplicate message",
            "Check" => "tech-writing-style-guide.acronyms"
          },
          {
            "Line" => 2,
            "Severity" => "warning",
            "Message" => "Duplicate message",
            "Check" => "tech-writing-style-guide.acronyms"
          }
        ]
      }.to_json
    end

    it "deduplicates acronym messages" do
      report = described_class.new(raw_output)
      report.format_linter_output

      expect(report.table_rows.size).to eq(1)
    end
  end
end