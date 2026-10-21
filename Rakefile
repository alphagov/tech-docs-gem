require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

namespace :jasmine do
  desc "Test JavaScript with headless browser"
  task :ci do
    sh "npm ci --include=dev && npm test"
  end
  desc "Test JavaScript in browser"
  task :server do
    sh "npm ci --include=dev && npm run test-server"
  end
end

desc "Lint Ruby and JavaScript"
task :lint do
  sh "rubocop -a spec/test-site documentation lib spec Rakefile"
  sh "npm ci --include=dev && npm run lint --silent"
end

task default: ["lint", "spec", "jasmine:ci"]
