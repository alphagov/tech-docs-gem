
def get_gem_root
  Gem::Specification.find_by_name("govuk_tech_docs").gem_dir
end

def vale_config_path
  File.join(get_gem_root, ".vale.ini")
end
