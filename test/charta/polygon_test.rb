require 'test_helper'

module Charta
  class PolygonTest < Charta::Test
    def test_exterior_ring
      geom = Charta.new_geometry('POLYGON((10 10,50 10,50 50,10 50,10 10), (1 1,5 1,5 5,1 5,1 1))', 4326)
      assert_equal Charta::Polygon, geom.class
      assert_equal Charta.new_geometry('LINESTRING(10 10,50 10,50 50,10 50,10 10)'), geom.exterior_ring
    end
  end
end
