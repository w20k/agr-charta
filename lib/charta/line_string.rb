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
        generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
        Point.new(generator.generate(point))
      end || []
    end
  end
end
