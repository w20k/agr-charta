# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class FromWkbTransformer < EwktTransformer
        # @return [Boolean]
        def handles?(value, format:)
          value.is_a?(String) && !!(value =~ /\A[A-F0-9]+\z/)
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          if srid.nil?
            Geometry.factory.parse_wkb(value)
          else
            RGeo::Geos.factory(srid: srid).parse_wkb(value)
          end
        end
      end
    end
  end
end
