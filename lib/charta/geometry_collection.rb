module Charta
  # Represent a Geometry with contains other geometries
  class GeometryCollection < Geometry
    def self.empty(srid = nil)
      srid = Charta.find_srid(srid.nil? ? :WGS84 : srid)
      new("SRID=#{srid};GEOMETRYCOLLECTION EMPTY")
    end
  end
end
