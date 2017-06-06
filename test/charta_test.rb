require 'test_helper'
require 'charta/version'

class ChartaTest < Charta::Test
  def test_that_it_has_a_version_number
    refute_nil ::Charta::VERSION
  end
end
