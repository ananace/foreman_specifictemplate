require File.expand_path('../lib/foreman_specifictemplate/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name        = 'foreman_specifictemplate'
  s.version     = ForemanSpecificTemplate::VERSION
  s.date        = Date.today.to_s
  s.authors     = ['Alexander Olofsson']
  s.email       = ['alexander.olofsson@liu.se', 'ace@haxalot.com']
  s.homepage    = 'http://github.com/ace13/foreman_specifictemplate'
  s.licenses    = ['GPL-3']
  s.summary     = 'This plug-in adds support for choosing arbitrary PXE template in The Foreman'
  s.description = s.summary

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rdoc'
end
