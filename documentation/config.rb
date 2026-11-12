require "govuk_tech_docs"

set :relative_links, true
activate :relative_assets

GovukTechDocs.configure(self)

if ENV["HTTP_PREFIX"].present?
  set :http_prefix, ENV["HTTP_PREFIX"]
end


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
