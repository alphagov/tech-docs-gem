require "middleman-core/renderers/redcarpet"
require "tmpdir"
require "timeout"

module GovukTechDocs
  class TechDocsHTMLRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
    include Redcarpet::Render::SmartyPants

    def initialize(options = {})
      @local_options = options.dup
      @app = @local_options[:context].app
      super
    end

    def paragraph(text)
      @app.api("<p>#{text.strip}</p>\n")
    end

    def header(text, level)
      anchor = UniqueIdentifierGenerator.instance.create(text, level)
      %(<h#{level} id="#{anchor}">#{text}</h#{level}>)
    end

    def image(link, *args)
      %(<a href="#{link}" target="_blank" rel="noopener noreferrer">#{super}</a>)
    end

    def table(header, body)
      %(<div class="table-container">
        <table>
          #{header}#{body}
        </table>
      </div>)
    end

    def block_code(code, lang)
      if lang == "mermaid"
        block_diagram(code)
      else
        super
      end
    end

    def block_diagram(code)
      mmdc = "#{__dir__}/../../node_modules/.bin/mmdc"
      Dir.mktmpdir do |tmp|
        input_path = "#{tmp}/input"
        output_path = "#{tmp}/output.svg"
        File.open(input_path, "w") { |f| f.write(code) }
        ok = exec_with_timeout("#{mmdc} -i #{input_path} -o #{output_path} --theme neutral", 2)
        if ok && File.exist?(output_path)
          File.read(output_path)
        else
          "<pre>#{code}</pre>"
        end
      end
    end

    def exec_with_timeout(cmd, timeout)
      pid = Process.spawn(cmd, { %i[err out] => :close, :pgroup => true })
      begin
        Timeout.timeout(timeout) do
          Process.waitpid(pid, 0)
          $?.exitstatus.zero?
        end
      rescue Timeout::Error
        Process.kill(15, -Process.getpgid(pid))
        false
      end
    end
  end
end
