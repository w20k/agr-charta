# frozen_string_literal: true

module Charta
  module Factory
    class SimpleGeometryFactory
      # @return [SimpleFeatureFactory]
      attr_reader :feature_factory

      # @param [SimpleFeatureFactory] feature_factory
      def initialize(feature_factory:)
        @feature_factory = feature_factory
      end

      def new_geometry(coordinates, srs: nil, format: nil)
        if coordinates.is_a?(::Charta::Geometry)
          coordinates
        else
          wrap(feature_factory.new_feature(coordinates, srs: srs, format: format))
        end
      end

      def empty_geometry(srs)
        wrap(feature_factory.empty_feature(srs))
      end

      protected

        def wrap(feature)
          case feature.geometry_type
          when RGeo::Feature::Point
            Point.new(feature)
          when RGeo::Feature::LineString
            LineString.new(feature)
          when RGeo::Feature::Polygon
            Polygon.new(feature)
          when RGeo::Feature::MultiPolygon
            MultiPolygon.new(feature)
          when RGeo::Feature::GeometryCollection
            GeometryCollection.new(feature)
          else
            Geometry.new(feature)
          end
        end
    end
  end
end