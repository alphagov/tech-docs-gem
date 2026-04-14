require "govuk_tech_docs"

GovukTechDocs.configure(self)

ignore "templates/*"

proxy "/a-proxied-page.html", "templates/proxy_template.html", locals: {
  title: "I am a title",
}

gem_root = File.expand_path("..", __dir__)
files.watch :reload, path: File.join(gem_root, "lib")

configure :development do
  ready do
    files.on_change :reload do |changed|
      changed.each do |file|
        next unless file.full_path.extname == ".rb"

        load file.full_path.to_s
      end
    end
  end
end
