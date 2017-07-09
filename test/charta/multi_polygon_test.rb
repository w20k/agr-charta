require 'test_helper'

module Charta
  class MultiPolygonTest < Charta::Test
    def test_polygons
      geom = Charta.new_geometry('MULTIPOLYGON(((10 10,50 10,50 50,10 50,10 10), (1 1,5 1,5 5,1 5,1 1)))', 4326)
      assert_equal Charta::MultiPolygon, geom.class
      assert_equal [Charta.new_geometry('POLYGON((10 10,50 10,50 50,10 50,10 10), (1 1,5 1,5 5,1 5,1 1))')], geom.polygons
    end
  end
end
