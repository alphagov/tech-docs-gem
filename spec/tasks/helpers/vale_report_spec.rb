# spec/tasks/helpers/vale_report_spec.rb
require "json"
require_relative "../../../lib/tasks/helpers/linter_report"
require_relative "../../../lib/tasks/helpers/vale_report"
puts Object.constants.grep(/Vale/)
RSpec.describe ValeLinterReport do
  let(:valid_json) do
    <<~JSON
      {
        "Files": [
          {
            "Path": "file1.md",
            "Alerts": [
              { "Severity": "error", "Message": "Bad thing", "Check": "Style.Rule" },
              { "Severity": "warning", "Message": "Less bad thing", "Check": "Style.Rule" }
            ]
          },
          {
            "Path": "file2.md",
            "Alerts": [
              { "Severity": "suggestion", "Message": "Suggestion here", "Check": "Style.Rule" }
            ]
          }
        ]
      }
    JSON
  end

  subject(:report) { described_class.new(valid_json) }

  describe "#initialize" do
    it "parses the JSON input" do
      expect(report.data).to be_a(Hash)
    end

    context "with invalid JSON" do
      it "raises an error" do
        expect {
          described_class.new("not json")
        }.to raise_error(JSON::ParserError)
      end
    end
  end

  describe "#files" do
    it "returns all files from the report" do
      expect(report.files.size).to eq(2)
    end
  end

  describe "#alerts" do
    it "returns flattened alerts" do
      expect(report.alerts.size).to eq(3)
    end
  end

  describe "#error_count" do
    it "counts errors" do
      expect(report.error_count).to eq(1)
    end
  end

  describe "#warning_count" do
    it "counts warnings" do
      expect(report.warning_count).to eq(1)
    end
  end

  describe "#suggestion_count" do
    it "counts suggestions" do
      expect(report.suggestion_count).to eq(1)
    end
  end

  describe "#by_severity" do
    it "groups alerts by severity" do
      grouped = report.by_severity

      expect(grouped["error"].size).to eq(1)
      expect(grouped["warning"].size).to eq(1)
      expect(grouped["suggestion"].size).to eq(1)
    end
  end

  describe "#files_with_errors" do
    it "returns files containing errors" do
      expect(report.files_with_errors).to include("file1.md")
      expect(report.files_with_errors).not_to include("file2.md")
    end
  end
end
