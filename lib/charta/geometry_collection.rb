module Charta
  # Represent a Geometry with contains other geometries
  class GeometryCollection < Geometry
    def self.empty(srid = nil)
      srid = Charta.find_srid(srid.nil? ? :WGS84 : srid)
      feature = Charta.new_feature("GEOMETRYCOLLECTION EMPTY", srid)
      new(feature)
    end

    def to_json_feature_collection
      features = []
      feature.each do |f|
        features << Charta.new_geometry(f).to_json_feature
      end
      { type: 'FeatureCollection', features: features }
    end
  end
end
