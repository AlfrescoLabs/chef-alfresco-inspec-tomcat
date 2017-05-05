# !/usr/bin/env rake
require 'yamllint/rake_task'

desc 'Runs cookstyle tests'
task :cookstyle do
  sh 'chef exec bundle exec cookstyle'
end

desc 'Runs yamllint checks'
task :yamllint do
  YamlLint::RakeTask.new do |t|
    t.paths = %w( \.*\.y*ml )
  end
end

task default: [:yamllint, :cookstyle]
