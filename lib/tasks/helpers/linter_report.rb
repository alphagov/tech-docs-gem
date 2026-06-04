class LinterReport
  attr_accessor :linter_name, :linter_raw_output, :output_summary, :output_detail, :output_summary_json, :output_detail_json

  def initialize
    raise NotImplementedError, "Subclass must set @linter_name in #initialize"
  end

  def format_linter_output
    raise NotImplementedError, "Subclass must implement #format_linter_output"
  end

  def set_raw_output
    warn "Subclass must implement #set_raw_output"
  end

  def get_raw_output
    raise "No raw output available.  Check you have run the linter task correctly" unless @linter_raw_output

    @linter_raw_output
  end

  def set_output_summary
    warn "Subclass must implement #set_output_summary"
  end

  def get_output_summary
    raise "No output summary available.  Check you have called set_output_summary" unless @output_summary

    @output_summary.join("\n")
  end

  def set_output_summary_json
    warn "Subclass must implement #set_output_summary_json"
  end

  def get_output_summary_json
    raise "No output summary json available.  Check you have called set_output_summary_json" unless @output_summary_json

    @output_summary_json
  end

  def set_output_detail(_output_detail)
    warn "Subclass must implement #set_output_detail"
  end

  def get_output_detail
    raise "No output detail available.  Check you have called set_output_detail" unless @output_detail

    @output_detail.join("\n")
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
