require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'jasmine'

RSpec::Core::RakeTask.new(:spec)

load 'jasmine/tasks/jasmine.rake'

task default: ['spec', 'jasmine:ci']
