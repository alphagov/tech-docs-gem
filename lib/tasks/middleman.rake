namespace :middleman do
  desc "Delete build directory and run bundle exec middleman build"
  task :build do
    if Dir.exist?("./build")
      puts "Target directory found at ./build.  Removing old build."
      FileUtils.rm_rf("./build")
    end
    sh "bundle exec middleman build"
  end
end