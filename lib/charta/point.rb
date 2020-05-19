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

    def distance(point)
      raise ArgumentError, "wrong type: Charta::Point required" if point.class.name != "Charta::Point"
      to_rgeo.distance(point.to_rgeo)
    end
  end
end
