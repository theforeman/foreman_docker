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
  s.summary     = 'Provision and manage Docker containers and images from Foreman'
  s.description = 'Provision and manage Docker containers and images from Foreman.'
  s.licenses    = ['GPL-3']

  s.files = Dir['{app,config,db,lib,locale}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*', '.rubocop.yml']

  s.add_dependency 'docker-api', '~> 1.17'
  s.add_dependency 'wicked', '~> 1.1'
end
