class LinterReport
  attr_accessor :linter_raw_output, :linter_summary_report, :linter_full_report

  def initialize(raw_output)
     puts "#{self.class} initialized."
     @linter_raw_output = raw_output
  end

  def format_linter_output
    raise NotImplementedError, "Subclass must implement #format_linter_output"
  end

  def get_raw_output
    raise "No raw output available.  Check you have run the linter task correctly" unless @linter_raw_output
    @linter_raw_output
  end

  def set_linter_summary_report
    raise "Subclass must implement #set_linter_summary_report"
  end

  def get_linter_summary_report
    raise "No output summary available.  Check you have called set_linter_summary_report" unless @linter_summary_report
    @linter_summary_report
  end

  def set_linter_full_report
    raise "Subclass must implement #set_linter_full_report"
  end

  def get_linter_full_report
    raise "No output detail available.  Check you have called set_linter_full_report" unless @linter_full_report
    @linter_full_report
  end

protected

  def set_output_text_color(text, severity)
    case severity.downcase
    when "error" then "\e[31m#{text}\e[0m" # Red
    when "warning" then "\e[33m#{text}\e[0m" # Yellow
    when "suggestion" then "\e[34m#{text}\e[0m" # Blue
    else "\e[36m#{text}\e[0m" # Cyan
    end
  end
end
