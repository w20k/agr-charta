module Charta
  module Coordinates
    class << self

      # Force coordinates to 2D
      def flatten(hash)
        map_coordinates(hash) { |position| position[0..1] }
      end

      def map_coordinates(hash, &block)
        case hash['type']
          when 'FeatureCollection'
            map_feature_collection_coordinates hash, &block
          when 'Feature'
            map_feature_coordinates hash, &block
          else
            map_geometry_coordinates hash, &block
        end
      end

      def normalize_4326_geometry(json)
        map_coordinates json do |(x, y)|
          [((x + 180.to_d) % 360.to_d) - 180.to_d, ((y + 90.to_d) % 180.to_d) - 90.to_d]
        end
      end

      private

        def map_feature_collection_coordinates(hash, &block)
          hash.merge 'features' => hash['features'].map { |feature| map_feature_coordinates feature, &block }
        end

        def map_feature_coordinates(hash, &block)
          hash.merge 'geometry' => map_geometry_coordinates(hash['geometry'], &block)
        end

        def map_geometry_coordinates(hash, &block)
          if hash['type'] == 'GeometryCollection'
            map_geometry_collection_coordinates hash, &block
          else
            coordinates = hash['coordinates']
            mapped =
              case hash['type']
                when 'Point' then
                  block.call coordinates
                when 'MultiPoint', 'LineString'
                  coordinates.map(&block)
                when 'MultiLineString', 'Polygon'
                  coordinates.map { |line| line.map(&block) }
                when 'MultiPolygon'
                  coordinates.map { |poly| poly.map { |line| line.map(&block) } }
                else
                  raise StandardError, "Cannot handle: #{hash['type'].inspect}. In #{hash.inspect}"
              end

            hash.merge 'coordinates' => mapped
          end
        end

        def map_geometry_collection_coordinates(hash, &block)
          hash.merge 'geometries' => hash['geometries'].map { |geometry| map_geometry_coordinates(geometry, &block) }
        end
    end
  end
end