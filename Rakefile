require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :jasmine do
  desc "Test JavaScript with headless browser"
  task :ci do
    sh "npm test"
  end
  desc "Test JavaScript in browser"
  task :server do
    sh "npm run test-server"
  end
end

desc "Lint Ruby and JavaScript"
task :lint do
  sh "rubocop example lib spec Rakefile"
  sh "npm run lint --silent"
end

task default: ["lint", "spec", "jasmine:ci"]
