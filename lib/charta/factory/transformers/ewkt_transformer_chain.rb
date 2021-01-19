# frozen_string_literal: true

module Charta
  module Factory
    module Transformers
      class EwktTransformerChain < EwktTransformer
        class << self
          def build
            new(
              Transformers::FromGeoJsonTransformer.new,
              Transformers::FromWkbTransformer.new,
              Transformers::FromGmlTransformer.new,
              Transformers::FromKmlTransformer.new,
              Transformers::EwktPassthrough.new
            )
          end
        end

        # @return [Array<EwktTransformer>]
        attr_reader :transformers

        def initialize(*transformers)
          @transformers = transformers
        end

        # @return [Boolean]
        def handles?(value, format:)
          transformers.any? { |t| t.handles?(value, format: format) }
        end

        # @param [String, Hash] value
        # @return [String] ewkt representation of value
        def transform(value, srid: nil, format: nil)
          transformer = transformers.detect { |t| t.handles?(value, format: format) }
          raise TransformationError.new('Not handled') if transformer.nil?

          transformer.transform(value, srid: srid, format: format)
        end
      end
    end
  end
end
