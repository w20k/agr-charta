# frozen_string_literal: true

module Charta
  module Factory
    class FeatureFactoryBase
      def new_feature(coordinates, srs: nil, format: nil)
        raise StandardError, 'Not implemented'
      end

      def empty_feature(srs = :WGS84)
        new_feature('GEOMETRYCOLLECTION EMPTY', srs: srs)
      end
    end
  end
end