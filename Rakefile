# !/usr/bin/env rake

require 'foodcritic'
require 'rspec/core/rake_task'

desc 'Runs cookstyle tests'
task :cookstyle do
  sh 'chef exec bundle exec cookstyle'
end

task default: [:cookstyle]
