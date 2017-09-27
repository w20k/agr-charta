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
      @polygons ||= feature._elements.map do |polygon|
        Polygon.new(polygon)
      end || []
    end
  end
end
