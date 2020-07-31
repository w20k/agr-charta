# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class FromGeoJsonTransformer < EwktTransformer
        # @return [Boolean]
        def handles?(value, format:)
          value.is_a?(Hash) || (value.is_a?(String) && Charta::GeoJSON.valid?(value)) # GeoJSON
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          Charta::GeoJSON.new(value, srid).to_ewkt
        end
      end
    end
  end
end
