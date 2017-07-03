$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sidejobs/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sidejobs'
  s.version     = Sidejobs::VERSION
  s.authors     = ['mmontossi']
  s.email       = ['mmontossi@museways.com']
  s.homepage    = 'https://github.com/mmontossi/sidejobs'
  s.summary     = 'Async jobs for rails'
  s.description = 'Versatile async database based jobs for rails.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1'

  s.add_development_dependency 'pg', '~> 0.21'
  s.add_development_dependency 'mocha', '~> 1.2'
end
