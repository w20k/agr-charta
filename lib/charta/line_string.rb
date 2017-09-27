module Charta
  # Represent a Geometry which contains points in a line string.
  class LineString < Geometry
    # Browse each point
    def each_point(&block)
      if block.arity == 1
        points.each(&block)
      elsif block.arity == 2
        points.each_with_index(&block)
      else
        raise 'Cannot browse each point without parameter'
      end
    end

    def points
      @points ||= feature.points.map do |point|
        Point.new(point)
      end || []
    end
  end
end
