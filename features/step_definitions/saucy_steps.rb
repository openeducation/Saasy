When /^I bootstrap the application for saucy$/ do
end

When /^I copy the locked Gemfile from this project$/ do
  in_current_dir do
    FileUtils.cp(File.join(PROJECT_ROOT, 'Gemfile.lock'), 'Gemfile.lock')
  end
end
