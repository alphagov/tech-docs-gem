require_relative "./linter_report"
require "json"

class ValeLinterReport < LinterReport
  attr_accessor :table_rows, :linter_severity_totals, :table_column_widths, :formatter

  def initialize(raw_output)
    @linter_name = "Vale"
    @linter_raw_output = raw_output
  end

  def format_linter_output
    if @linter_raw_output.strip.empty?
      @table_rows = []
      @totals = { "error" => 0, "warning" => 0, "suggestion" => 0 }
    else
      set_table_rows
      set_linter_severity_totals_from_rows
    end

    set_output_detail
    set_output_summary
    set_output_summary_json
  end

  def set_output_detail
    add_formatted_rows_to_detail_output
  end

  def set_output_summary
    if @linter_severity_totals.nil?
      set_linter_severity_totals_from_rows
    end

    error = @linter_severity_totals["error"]
    warning = @linter_severity_totals["warning"]
    suggestion = @linter_severity_totals["suggestion"]

    @output_summary = []

    @output_summary << "\n#{'=' * [0, 40].max}"
    @output_summary << "\e[1m Vale summary\e[0m"
    @output_summary << "-" * [0, 40].max
    @output_summary << "  Errors:      #{error.positive? ? set_output_text_color(error, 'error') : error}"
    @output_summary << "  Warnings:    #{warning.positive? ? set_output_text_color(warning, 'warning') : warning}"
    @output_summary << "  Suggestions: #{suggestion.positive? ? set_output_text_color(suggestion, 'suggestion') : suggestion}"
    @output_summary << "-" * [0, 40].max
  end

  def set_output_summary_json
    if @linter_severity_totals.nil?
      set_linter_severity_totals_from_rows
    end
    @output_summary_json = JSON.generate(@linter_severity_totals)
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
    @formatter = "%-#{@table_column_widths[:file]}s | %-#{@table_column_widths[:line]}s | %-#{@table_column_widths[:severity]}s | %-#{@table_column_widths[:message]}s | %s"
  end

  def add_formatted_header_to_detail_output
    if @output_detail.nil?
      @output_detail = []
    end

    header = sprintf(@formatter, "File", "Line", "Severity", "Message", "Rule")
    @output_detail << "\e[1m🔍 Vale Style Linting Report\e[0m\n\n"
    @output_detail << "\e[1m#{header}\e[0m"
    @output_detail << "-" * header.length
  end

  def add_formatted_rows_to_detail_output
    set_table_column_widths
    set_table_formatter
    add_formatted_header_to_detail_output

    @table_rows.each do |row|
      @output_detail << format_row(row)
    end
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
      puts "\e[Error parsing Vale payload:\e[0m\n#{stdout}"
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
