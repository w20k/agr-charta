module Charta
  # Represent a Point
  class Point < Geometry
    def x
      feature.x
    end
    alias longitude x

    def y
      feature.y
    end
    alias latitude y
  end
end
