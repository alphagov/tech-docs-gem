require "govuk_tech_docs"

set :http_prefix, "/tech-docs-gem"

# set :relative_links, true
activate :relative_assets
activate :directory_indexes


GovukTechDocs.configure(self)

configure :development do
  gem_root = File.expand_path("..", __dir__)
  files.watch :reload, path: File.join(gem_root, "lib")
  ready do
    files.on_change :reload do |changed|
      changed.each do |file|
        next unless file.full_path.extname == ".rb"

        load file.full_path.to_s
      end
    end
  end
end
