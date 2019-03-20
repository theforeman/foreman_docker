$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'foreman_docker/version'
require 'date'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'foreman_docker'
  s.version     = ForemanDocker::VERSION
  s.date        = Date.today.to_s
  s.authors     = ['Daniel Lobato, Amos Benari']
  s.email       = ['dlobatog@redhat.com, abenari@redhat.com']
  s.homepage    = 'http://github.com/theforeman/foreman-docker'
  s.summary     = 'This version does not provide any functionality and only makes plugin removal easier.'
  s.description = 'This version does not provide any functionality and only makes plugin removal easier.'
  s.licenses    = ['GPL-3.0']

  s.files = Dir['{app,config,db,lib,locale}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*', '.rubocop.yml']

  s.add_dependency 'deface', '< 2.0'
  s.add_dependency 'wicked', '~> 1.1'

  s.add_development_dependency 'rubocop', '0.52.0'
end
