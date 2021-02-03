require 'json'

module Charta
  # Represents a Geometry with SRID
  class GeoJSON
    attr_reader :srid

    def initialize(data, srid = :WGS84)
      srid ||= :WGS84
      @json = Coordinates.flatten(data.is_a?(Hash) ? data : JSON.parse(data))
      lsrid = @json['crs']['properties']['name'] if @json.is_a?(Hash) &&
                                                    @json['crs'].is_a?(Hash) &&
                                                    @json['crs']['properties'].is_a?(Hash)
      lsrid ||= srid
      @srid = ::Charta.find_srid(lsrid)

      @json = Coordinates.normalize_4326_geometry(@json) if @srid.to_i == 4326
    end

    def geom
      Charta.new_geometry(to_ewkt)
    end

    def to_hash
      @json
    end

    def to_ewkt
      "SRID=#{srid};" + EwktSerializer.object_to_ewkt(@json)
    end

    def valid?
      to_ewkt
      true
    rescue
      false
    end

    class << self
      # Test is given data is a valid GeoJSON
      def valid?(data, srid = :WGS84)
        new(data, srid).valid?
      rescue
        false
      end

      def flatten(hash)
        Coordinates.flatten hash
      end

      %i[
        object_to_ewkt feature_collection_to_ewkt geometry_collection_to_ewkt feature_to_ewkt point_to_ewkt line_string_to_ewkt
        polygon_to_ewkt multi_point_to_ewkt multi_line_string_to_ewkt multipolygon_to_ewkt multi_polygon_to_ewkt
      ].each do |m|
        define_method m do |*args|
          EwktSerializer.send m, *args
        end
      end
    end
  end
end
