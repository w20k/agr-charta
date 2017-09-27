require 'test_helper'

module Charta
  class GeometryCollectionTest < Charta::Test
    def test_empty
      geom = Charta::GeometryCollection.empty
      assert geom.feature.is_empty?
    end
  end
end
