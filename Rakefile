require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'jasmine'

RSpec::Core::RakeTask.new(:spec)

load 'jasmine/tasks/jasmine.rake'

task :lint do
  sh "govuk-lint-ruby example lib spec Rakefile"
end

task default: ['lint', 'spec', 'jasmine:ci']
