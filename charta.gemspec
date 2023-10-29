require_relative 'lib/charta/version'

Gem::Specification.new do |spec|
  spec.name = 'charta'
  spec.version = Charta::VERSION
  spec.authors = ['Ekylibre developers']
  spec.email = ['dev@ekylibre.com']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.summary = 'Simple tool over geos and co'
  spec.required_ruby_version = '>= 2.6.0'
  spec.homepage = 'https://gitlab.com/ekylibre'
  spec.license = 'AGPL-3.0-only'

  spec.files = Dir.glob(%w[lib/**/*.rb *.gemspec])

  spec.require_paths = ['lib']

  # spec.add_dependency 'activesupport', '6.0.6.1'
  spec.add_dependency 'activesupport', '>= 5.0'
  spec.add_dependency 'json', '>= 1.8.0'
  spec.add_dependency 'nokogiri', '>= 1.13.10'
  spec.add_dependency 'rgeo', '~> 2.0'
  spec.add_dependency 'rgeo-geojson', '~> 2.0'
  spec.add_dependency 'rgeo-proj4'
  spec.add_dependency 'victor', '~> 0.3.4'
  spec.add_dependency 'zeitwerk', '~> 2.4.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.20.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '1.50'
end
