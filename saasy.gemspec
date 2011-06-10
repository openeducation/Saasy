Gem::Specification.new do |s|
  s.name        = "saasy"
  s.version     = "0.0.1"
  s.authors      = ['thoughtbot, inc.', 'Joe Ferris', 'Mike Burns', 'Chad Pytel', 'Matthew Burket'] 
  s.email       = "Matthew@AssignItApp.com"
  s.homepage    = "http://github.com/mab879/saasy"
  s.summary     = "Saas Rails engine."
  s.description = "Clearance-based Rails engine for Software as a Service (Saas) that provides account and project management."

  s.files        = Dir["{app,config,features,lib,spec}/**/*", "[A-Z]*", "CHANGELOG.md"] - ["Gemfile.lock"]
  s.require_path = "lib"

 s.add_development_dependency('aruba')
 s.add_dependency('braintree', '>= 2.6.2')
 s.add_dependency('clearance', '~> 0.11.0')
 s.add_dependency('formtastic', '>= 1.2')
 s.add_dependency('railties', '3.0.3')
 s.add_dependency('sham_rack', '1.3.3')
 s.add_dependency('sinatra', '>= 1.1.2')

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
