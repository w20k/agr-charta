lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'charta/version'

Gem::Specification.new do |spec|
  spec.name          = 'charta'
  spec.version       = Charta::VERSION
  spec.authors       = ['Brice TEXIER']
  spec.email         = ['brice@ekylibre.com']

  spec.summary       = 'Simple tool over geos and co'
  spec.homepage      = 'https://github.com/ekylibre/charta'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.7.0'
  spec.add_dependency 'rgeo', '~> 0.6.0'
  spec.add_dependency 'json', '>= 1.8.0'
  spec.add_dependency 'rgeo-geojson', '~> 0.4.3'
  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'byebug'
end
