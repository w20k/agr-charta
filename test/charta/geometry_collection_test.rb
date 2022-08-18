require 'test_helper'

module Charta
  class GeometryCollectionTest < Charta::Test
    def test_empty
      geom = Charta::GeometryCollection.empty
      assert geom.feature.empty?
    end

    def test_geojson_feature_collection_conversion
      geometry_collection = 'GEOMETRYCOLLECTION(POLYGON((7.40882456302643 48.1158768860692,7.40679681301117 48.1167274678089,7.40678608417511 48.1167220957579,7.40882456302643 48.1158679325024,7.40882456302643 48.1158768860692)),POINT(4 6),LINESTRING(4 6,7 10))'
      feature_collection = '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[7.40882456302643,48.1158768860692],[7.40679681301117,48.1167274678089],[7.40678608417511,48.1167220957579],[7.40882456302643,48.1158679325024],[7.40882456302643,48.1158768860692]]]}},{"type":"Feature","properties":{},"geometry":{"type":"Point","coordinates":[4.0,6.0]}},{"type":"Feature","properties":{},"geometry":{"type":"LineString","coordinates":[[4.0,6.0],[7.0,10.0]]}}]}'

      geom = Charta.new_geometry(geometry_collection)
      assert_equal feature_collection, geom.to_json_feature_collection.to_json
    end
  end
end
