#coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'job_hunter'
  gem.version       = '0.0.0'
  gem.date          = '2014-05-09'
  gem.authors       = ['Ryan Moser']
  gem.email         = 'ryanpmoser@gmail.com'
  gem.homepage      = 'https://github.com/moserrya/job_hunter'
  gem.summary       = 'A helper for custom Delayed Jobs'
  gem.description   = 'A gem to help reduce boilerplate when enqueing, finding, and deleting Delayed Jobs'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'delayed_job', ['>= 3.0', '< 5.0']

  gem.add_development_dependency "rake", '~> 10'
  gem.add_development_dependency "rspec", '~> 3'
end
