module Charta
  # Represent a Geometry with contains other geometries
  class GeometryCollection < Geometry
    def self.empty(srid = nil)
      srid = Charta.find_srid(srid.nil? ? :WGS84 : srid)
      feature = Charta.new_feature('GEOMETRYCOLLECTION EMPTY', srid)
      new(feature)
    end

    def to_json_feature_collection(collection_properties = [])
      features = feature.each.with_index.collect do |f, i|
        properties = {}
        properties = collection_properties[i] unless collection_properties[i].nil?

        Charta.new_geometry(f).to_json_feature(properties)
      end

      { type: 'FeatureCollection', features: features }
    end
  end
end
