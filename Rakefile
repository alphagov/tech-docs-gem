require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "jasmine"

RSpec::Core::RakeTask.new(:spec)

load "jasmine/tasks/jasmine.rake"

desc "Lint Ruby and JavaScript"
task :lint do
  sh "rubocop example lib spec Rakefile"
  sh "npm run lint --silent"
end

task default: ["lint", "spec", "jasmine:ci"]
