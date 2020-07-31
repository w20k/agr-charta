# frozen_string_literal: true

module Charta
  module Factory
    class SimpleFeatureFactory < FeatureFactoryBase
      class << self
        def build
          new(
            ewkt_builder: EwktFeatureBuilder.new,
            srid_provider: SridProvider.build,
            transformer: Transformers::EwktTransformerChain.build
          )
        end
      end

      # @return [EwktFeatureBuilder]
      attr_reader :ewkt_builder
      # @return [SridProvider]
      attr_reader :srid_provider
      # @return [Transformers::EwktTransformer]
      attr_reader :transformer

      def initialize(ewkt_builder:, srid_provider:, transformer:)
        @ewkt_builder = ewkt_builder
        @srid_provider = srid_provider
        @transformer = transformer
      end

      def new_feature(coordinates, srs: nil, format: nil)
        if coordinates.is_a?(Charta::Geometry)
          coordinates
        elsif coordinates.is_a?(RGeo::Feature::Instance)
          Geometry.feature(coordinates)
        elsif coordinates.to_s =~ /\A[[:space:]]*\z/
          empty_feature(srs)
        else
          convert_feature(coordinates, srs: srs, format: format)
        end
      end

      private

        def convert_feature(coordinates, srs: nil, format: nil)
          srid = srs.nil? ? nil : srid_provider.find(srs)

          ewkt_builder.from_ewkt(transformer.transform(coordinates, srid: srid, format: format))
        end
    end
  end
end
