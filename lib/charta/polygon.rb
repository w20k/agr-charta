module Charta
  # Represent a Geometry with contains only polygons
  class Polygon < Geometry
    def exterior_ring
      unless defined? @exterior_ring
        generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
        @exterior_ring = Charta.new_geometry(generator.generate(feature.exterior_ring))
      end
      @exterior_ring
    end
  end
end
