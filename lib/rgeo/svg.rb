module RGeo
  module SVG
    class << self
      def encode(feature)
        send('encode_' + Charta.underscore(feature.geometry_type.type_name), feature)
      end

      protected

        def encode_point(feature)
          'M' + coordinates(feature)
        end

        def encode_multi_point(feature)
          points = []
          feature.each do |point|
            points << encode_point(point)
          end
          points.join(' ')
        end

        def encode_line_string(feature)
          points = []
          feature.points.each do |point|
            points << coordinates(point)
          end
          'M' + points.join('L')
        end

        def encode_multi_line_string(feature)
          line_strings = []
          feature.each do |line_string|
            line_strings << encode_line_string(line_string)
          end
          line_strings.join(' ')
        end

        def encode_polygon(feature)
          rings = []
          # TODO: Optimize useless last point repetition
          rings << encode_line_string(feature.exterior_ring) + 'Z'
          feature.interior_rings.each do |ring|
            rings << encode_line_string(ring) + 'Z'
          end
          rings.join(' ')
        end

        def encode_multi_polygon(feature)
          polygons = []
          feature.each do |polygon|
            polygons << encode_polygon(polygon)
          end
          polygons.join(' ')
        end

        def encode_geometry_collection(feature)
          geometries = []
          feature.each do |geometry|
            geometries << encode(geometry)
          end
          geometries.join(' ')
        end

        def coordinates(feature)
          feature.x.to_s + ',' + feature.y.to_s
        end
    end
  end
end
