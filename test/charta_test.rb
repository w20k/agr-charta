require 'test_helper'
require 'charta/version'

class ChartaTest < Charta::Test
  def test_that_it_has_a_version_number
    refute_nil ::Charta::VERSION
  end

  def test_make_line
    line_string = Charta.make_line(['SRID=4326;POINT(3 4)', 'SRID=4326;POINT(10 20)'])
    assert Charta::LineString, line_string.class
    assert_equal Charta.new_point(4, 3, 4326), line_string.points[0]
  end
end
