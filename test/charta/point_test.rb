require 'test_helper'

module Charta
  class LineStringTest < Charta::Test
    def test_coordinates
      geom = Charta.new_geometry('POINT(20 25)', 4326)
      assert_equal Charta::Point, geom.class
      assert_equal 20, geom.x
      assert_equal 25, geom.y
    end
  end
end
