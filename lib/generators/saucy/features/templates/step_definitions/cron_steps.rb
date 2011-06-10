require 'rake'

module RakeHelpers
  def fake_rake
    old_rake = Rake.application
    rake = Rake::Application.new
    Rake.application = rake
    task :environment
    yield(rake)
  ensure
    Rake.application = old_rake
  end
end

World(RakeHelpers)

When /^the daily Saucy jobs are processed$/ do
  fake_rake do |rake|
    Saucy::Engine.new.load_tasks
    rake['saucy:daily'].invoke
  end
end

