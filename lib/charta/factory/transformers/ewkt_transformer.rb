# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class EwktTransformer
        # @return [Boolean]
        def handles?(value, format:)
          false
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          raise StandardError.new('Not implemented')
        end
      end
    end
  end
end
