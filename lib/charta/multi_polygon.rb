module Charta
  # Represent a Geometry with contains only polygons
  class MultiPolygon < GeometryCollection
    def each_polygon(&block)
      if block.arity == 1
        polygons.each(&block)
      elsif block.arity == 2
        polygons.each_with_index do |polygon, index|
          yield polygon, index + 1
        end
      else
        raise 'Cannot browse each polygon without parameter'
      end
    end

    # Extract polygons ordered by 'PointOnSurface' position
    def polygons
      unless defined? @polygons
        @polygons = []
        feature.each do |polygon|
          generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
          @polygons << Polygon.new(generator.generate(polygon))
        end
      end
      @polygons
    end
  end
end
