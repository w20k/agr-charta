require 'test_helper'

module Charta
  class LineStringTest < Charta::Test
    def test_points
      geom = Charta.new_geometry('LINESTRING(3 4,10 50,20 25)', 4326)
      assert_equal [Charta.new_point(4, 3, 4326), Charta.new_point(50, 10, 4326), Charta.new_point(25, 20, 4326)], geom.points
    end
  end
end
