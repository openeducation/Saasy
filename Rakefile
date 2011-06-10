require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/gempackagetask'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

desc 'Default: run all tests'
task :default => [:spec, :cucumber]

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = "--format progress"
end

eval("$specification = begin; #{IO.read('saucy.gemspec')}; end")
Rake::GemPackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

gem_file = "pkg/#{$specification.name}-#{$specification.version}.gem"

desc "Build and install the latest gem"
task :install => :gem do
  sh("gem install --local #{gem_file}")
end

desc "Build and release the latest gem"
task :release => :gem do
  sh("gem push #{gem_file}")
end

