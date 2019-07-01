module Charta
  module EwktSerializer

    class << self
      def object_to_ewkt(hash)
        type = hash[:type] || hash['type']
        send("#{type.gsub(/(.)([A-Z])/, '\1_\2').downcase}_to_ewkt", hash)
      end

      private

        def feature_collection_to_ewkt(hash)
          return 'GEOMETRYCOLLECTION EMPTY' if hash['features'].nil?
          'GEOMETRYCOLLECTION(' + hash['features'].collect do |feature|
            object_to_ewkt(feature)
          end.join(', ') + ')'
        end

        def geometry_collection_to_ewkt(hash)
          return 'GEOMETRYCOLLECTION EMPTY' if hash['geometries'].nil?
          'GEOMETRYCOLLECTION(' + hash['geometries'].collect do |feature|
            object_to_ewkt(feature)
          end.join(', ') + ')'
        end

        def feature_to_ewkt(hash)
          object_to_ewkt(hash['geometry'])
        end

        def point_to_ewkt(hash)
          return 'POINT EMPTY' if hash['coordinates'].nil?
          'POINT(' + hash['coordinates'].join(' ') + ')'
        end

        def line_string_to_ewkt(hash)
          return 'LINESTRING EMPTY' if hash['coordinates'].nil?
          'LINESTRING(' + hash['coordinates'].collect do |point|
            point.join(' ')
          end.join(', ') + ')'
        end

        def polygon_to_ewkt(hash)
          return 'POLYGON EMPTY' if hash['coordinates'].nil?
          'POLYGON(' + hash['coordinates'].collect do |hole|
            '(' + hole.collect do |point|
              point.join(' ')
            end.join(', ') + ')'
          end.join(', ') + ')'
        end

        def multi_point_to_ewkt(hash)
          return 'MULTIPOINT EMPTY' if hash['coordinates'].nil?
          'MULTIPOINT(' + hash['coordinates'].collect do |point|
            '(' + point.join(' ') + ')'
          end.join(', ') + ')'
        end

        def multi_line_string_to_ewkt(hash)
          return 'MULTILINESTRING EMPTY' if hash['coordinates'].nil?
          'MULTILINESTRING(' + hash['coordinates'].collect do |line|
            '(' + line.collect do |point|
              point.join(' ')
            end.join(', ') + ')'
          end.join(', ') + ')'
        end

        def multipolygon_to_ewkt(hash)
          return 'MULTIPOLYGON EMPTY' if hash['coordinates'].nil?
          'MULTIPOLYGON(' + hash['coordinates'].collect do |polygon|
            '(' + polygon.collect do |hole|
              '(' + hole.collect do |point|
                point.join(' ')
              end.join(', ') + ')'
            end.join(', ') + ')'
          end.join(', ') + ')'
        end

        # for PostGIS ST_ASGeoJSON compatibility
        def multi_polygon_to_ewkt(hash)
          return 'MULTIPOLYGON EMPTY' if hash['coordinates'].nil?
          'MULTIPOLYGON(' + hash['coordinates'].collect do |polygon|
            '(' + polygon.collect do |hole|
              '(' + hole.collect do |point|
                point.join(' ')
              end.join(', ') + ')'
            end.join(', ') + ')'
          end.join(', ') + ')'
        end
    end

  end
end