require_relative "./linter_report"
require "json"

class ValeLinterReport < LinterReport
  attr_accessor :table_rows, :linter_severity_totals, :table_column_widths, :formatter, :linter_summary_report_json, :linter_full_report_json

  def format_linter_output
    if @linter_raw_output.strip.empty?
      @table_rows = []
      @linter_severity_totals = { "error" => 0, "warning" => 0, "suggestion" => 0 }
    else
      set_table_rows
      set_linter_severity_totals_from_rows
    end

    set_linter_full_report
    set_linter_summary_report
    set_linter_summary_report_json
  end

  def set_linter_full_report
    add_formatted_rows_to_detail_output
  end

  def set_linter_summary_report
    if @linter_severity_totals.nil?
      set_linter_severity_totals_from_rows
    end

    error = @linter_severity_totals["error"]
    warning = @linter_severity_totals["warning"]
    suggestion = @linter_severity_totals["suggestion"]

    @linter_summary_report = []

    @linter_summary_report << "\n#{'=' * [0, 40].max}"
    @linter_summary_report << "\e[1m Vale summary\e[0m"
    @linter_summary_report << "-" * [0, 40].max
    @linter_summary_report << "  Errors:      #{error.positive? ? set_output_text_color(error, 'error') : error}"
    @linter_summary_report << "  Warnings:    #{warning.positive? ? set_output_text_color(warning, 'warning') : warning}"
    @linter_summary_report << "  Suggestions: #{suggestion.positive? ? set_output_text_color(suggestion, 'suggestion') : suggestion}"
    @linter_summary_report << "-" * [0, 40].max
    @linter_summary_report.join("\n")
  end

  def set_linter_summary_report_json
    if @linter_severity_totals.nil?
      set_linter_severity_totals_from_rows
    end
    @linter_summary_report_json = JSON.generate(@linter_severity_totals)
  end

private

  def set_table_column_widths
    if @table_rows.nil?
      set_table_rows
    end

    @table_column_widths = %i[file line severity message rule].each_with_object({}) do |col, acc|
      all_values = @table_rows.map { |row| row[col].to_s }
      acc[col] = [col.to_s.length, *all_values.map(&:length)].max
    end
  end

  def set_table_formatter
    if @table_column_widths.nil?
      set_table_column_widths
    end
    @formatter = "%-#{@table_column_widths[:file]}s | %-#{@table_column_widths[:line]}s | %-#{@table_column_widths[:severity]}s | %-#{@table_column_widths[:message]}s | %-#{@table_column_widths[:rule]}s"
  end

  def add_formatted_header_to_detail_output
    if @linter_full_report.nil?
      @linter_full_report = []
    end

    header = sprintf(@formatter, "File", "Line", "Severity", "Message", "Rule")
    @linter_full_report << "\e[1m🔍 Vale Style Linting Report\e[0m\n\n"
    @linter_full_report << "\e[1m#{header}\e[0m"
    @linter_full_report << "-" * header.gsub(/\e\[[0-9;]*m/, "").length
  end

  def add_formatted_rows_to_detail_output
    set_table_column_widths
    set_table_formatter
    add_formatted_header_to_detail_output

    @table_rows.each do |row|
      @linter_full_report << format_row(row)
    end
    @linter_full_report.join("\n")
  end

  def set_linter_severity_totals_from_rows
    if @table_rows.nil?
      set_table_rows
    end

    default_totals = { "error" => 0, "warning" => 0, "suggestion" => 0 }

    @linter_severity_totals = default_totals.merge(
      @table_rows
        .map { |r| r[:severity] }
        .compact # drops any actual nils
        .tally,
    )
  end

  def format_row(row)
    colored_severity = set_output_text_color(row[:severity].upcase, row[:severity])
    severity_padding = " " * (@table_column_widths[:severity] - row[:severity].length)
    padded_severity = "#{colored_severity}#{severity_padding}"

    sprintf(
      @formatter,
      row[:file], row[:line], padded_severity, row[:message], row[:rule]
    )
  end

  def set_table_rows
    begin
      rows_json = JSON.parse(@linter_raw_output)
    rescue JSON::ParserError
      puts "\e[Error parsing Vale payload:\e[0m\n#{@linter_raw_output}"
      exit 1
    end

    unique_rows = []

    rows_json.each do |file_path, alerts|
      next if alerts.empty?

      seen_messages = Set.new

      alerts.each do |alert|
        msg = alert["Message"]
        # Vale will hilghlight every instance of an infraction, sometimes this is unhelpful.  For example the acronyms rule needs to highlight an acronym is not defined in the first use
        # it does not need to then point out every single time it is referenced in the document, so we check for itentical messages for specific rules
        if seen_messages.include?(msg) && alert["Check"].downcase == "tech-writing-style-guide.acronyms"
          next
        end

        seen_messages.add(msg)
        unique_rows << {
          file: file_path,
          line: alert["Line"].to_s,
          severity: alert["Severity"],
          message: msg,
          rule: alert["Check"],
        }
      end
    end
    @table_rows = unique_rows
  end
end
