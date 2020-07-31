# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class EwktPassthrough < EwktTransformer
        # @return [Boolean]
        def handles?(value, format:)
          value.is_a?(String) && format.nil?
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          value
        end
      end
    end
  end
end