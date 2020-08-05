require_relative 'lib/charta/version'

Gem::Specification.new do |spec|
  spec.name = 'charta'
  spec.version = Charta::VERSION
  spec.required_ruby_version = '>= 2.4.4'
  spec.authors = ['Brice TEXIER']
  spec.email = ['brice@ekylibre.com']

  spec.summary = 'Simple tool over geos and co'
  spec.homepage = 'https://gitlab.com/ekylibre/charta'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_dependency 'json', '>= 1.8.0'
  spec.add_dependency 'nokogiri', '>= 1.7.0'
  spec.add_dependency 'rgeo', '~> 2.0'
  spec.add_dependency 'rgeo-geojson', '~> 2.0'
  spec.add_dependency 'rgeo-proj4', '~> 2.0'
  spec.add_dependency 'zeitwerk', '~> 2.4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
end
