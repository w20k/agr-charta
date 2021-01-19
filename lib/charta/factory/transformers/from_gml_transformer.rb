# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class FromGmlTransformer < EwktTransformer
        # @return [Boolean]
        def handles?(value, format:)
          value.is_a?(String) && format == 'gml' && Charta::GML.valid?(value)
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          Charta::GML.new(value, srid).to_ewkt
        end
      end
    end
  end
end
