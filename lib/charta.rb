# Gathers geomatic calculations
# Completes RGeo
require 'rgeo'
require 'charta/geometry'
require 'charta/geometry_collection'
require 'charta/point'
require 'charta/line_string'
require 'charta/polygon'
require 'charta/multi_polygon'
require 'charta/bounding_box'
require 'charta/geo_json'
require 'charta/gml'
require 'charta/kml'
require 'string'

require 'byebug'

# Charta aims to supply easy geom/geog tools
module Charta
  SRS = {
    WGS84: 4326,
    RGF93: 2143
  }

  class << self
    def new_geometry(coordinates, srs = nil, format = nil, flatten_collection = true, options = {})
      geom_ewkt = nil
      if coordinates.to_s =~ /\A[[:space:]]*\z/
        geom_ewkt = empty_geometry(srs).to_ewkt
      elsif coordinates.is_a?(::Charta::Geometry)
        geom_ewkt = coordinates.ewkt
      elsif coordinates.is_a?(Hash) || (coordinates.is_a?(String) && ::Charta::GeoJSON.valid?(coordinates)) # GeoJSON
        srid = srs ? find_srid(srs) : :WGS84
        # select_value("SELECT ST_AsEWKT(ST_GeomFromEWKT('#{::Charta::GeoJSON.new(coordinates, srid).to_ewkt}'))")
        geom_ewkt = ::Charta::GeoJSON.new(coordinates, srid).to_ewkt
      elsif coordinates.is_a?(String)
        geom_ewkt = if coordinates =~ /\A[A-F0-9]+\z/ # WKB
                      if srs && srid = find_srid(srs)
                        # select_value("SELECT ST_AsEWKT(ST_GeomFromText(E'\\\\x#{coordinates}', #{srid}))")
                        generate_ewkt RGeo::Geos.factory(srid: srid).parse_wkb(coordinates)
                      else
                        # select_value("SELECT ST_AsEWKT(ST_GeomFromEWKB(E'\\\\x#{coordinates}'))")
                        # parser = RGeo::WKRep::WKBParser.new(factory, support_ewkb: true)
                        generate_ewkt Geometry.factory.parse_wkb(coordinates)
                      end
                    elsif format == 'gml' && ::Charta::GML.valid?(coordinates)
                      # required format 'cause kml geometries return empty instead of failing
                      ::Charta::GML.new(coordinates, srid).to_ewkt
                    elsif format == 'kml' && ::Charta::KML.valid?(coordinates)
                      ::Charta::KML.new(coordinates).to_ewkt
                    else # WKT expected
                      # byebug
                      if srs && srid = find_srid(srs)
                        # select_value("SELECT ST_AsEWKT(ST_GeomFromText('#{coordinates}', #{srid}))")
                        generate_ewkt RGeo::Geos.factory(srid: srid).parse_wkt(coordinates)
                      else
                        # select_value("SELECT ST_AsEWKT(ST_GeomFromEWKT('#{coordinates}'))")
                        generate_ewkt Geometry.feature(coordinates)
                      end
                    end
      else
        raise coordinates.inspect
        geom_ewkt = select_value("SELECT ST_AsEWKT(ST_GeomFromText('#{coordinates.as_text}', #{coordinates.srid}))")
      end
      if geom_ewkt.to_s =~ /\A[[:space:]]*\z/
        raise ArgumentError, "Invalid data: coordinates=#{coordinates.inspect}, srid=#{srid.inspect}"
      end
      # select_value("SELECT GeometryType(ST_GeomFromEWKT('#{geom_ewkt}'))").to_s.strip
      type = Geometry.feature(geom_ewkt).geometry_type
      puts type.inspect
      geom = case type
             when RGeo::Feature::Point then
               Point.new(geom_ewkt)
             when RGeo::Feature::LineString then
               LineString.new(geom_ewkt)
             when RGeo::Feature::Polygon then
               Polygon.new(geom_ewkt)
             when RGeo::Feature::MultiPolygon then
               MultiPolygon.new(geom_ewkt, flatten_collection, options)
             when RGeo::Feature::GeometryCollection then
               GeometryCollection.new(geom_ewkt, flatten_collection, options)
             else
               Geometry.new(geom_ewkt)
             end
      geom
    end

    def new_point(lat, lon, srid = 4326)
      Point.new("SRID=#{srid};POINT(#{lon} #{lat})")
    end

    def make_line(points, options = {})
      options[:srid] ||= new_geometry(points.first).srid if points.any?
      options[:srid] ||= 4326
      list = points.map { |p| new_geometry(p).geom }
      new_geometry(select_value("SELECT ST_AsEWKT(ST_MakeLine(ARRAY[#{list.join(', ')}]))"))
    end

    def empty_geometry(srid = :WGS84)
      GeometryCollection.empty(srid)
    end

    # Execute a query
    def select_value(query)
      # byebug
      raise "No more ActiveRecord::Base.connection.select_value(query)"
    end

    def select_values(query)
      raise "No more ActiveRecord::Base.connection.select_values(query)"
    end

    # Execute a query
    def select_row(query)
      raise "No more ActiveRecord::Base.connection.select_rows(query).first"
    end

    def generate_ewkt(feature)
      generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
      generator.generate(feature)
    end

    def parse_ewkt(coordinates)
      # parser = RGeo::WKRep::WKTParser.new(factory, support_ewkt: true)
      # factory.parse_wkt(coordinates)
      coordinates
    end

    def find_system_by_srid(_srid)
      nil
    end

    def find_system_by_urn(_urn)
      nil
    end

    def find_system(_srname)
      nil
    end



    # Check and returns the SRID matching with srname or SRID.
    def find_srid(srname_or_srid)
      if srname_or_srid.to_s =~ /\Aurn:ogc:def:crs:.*\z/
        srname_or_srid.split(':').last
      elsif srname_or_srid.to_s =~ /\AEPSG::?(\d{4,5})\z/
        srname_or_srid.split(':').last
      elsif srname_or_srid.to_s =~ /\A\d+\z/
        srname_or_srid.to_i
      else
        SRS[srname_or_srid] || srname_or_srid
      end
    end

    def clean_for_active_record(value, options = {})
      return nil if value.to_s =~ /\A[[:space:]]*\z/
      value = if value.is_a?(Hash) || (value.is_a?(String) && value =~ /\A\{.*\}\z/)
                from_geojson(value)
              else
                new_geometry(value)
              end
      value.flatten.convert_to(options[:type]).to_rgeo
    end

    def from(format, data)
      unless respond_to?("from_#{format}")
        raise "Unknown format: #{format.inspect}"
      end
      send("from_#{format}", data)
    end

    def from_gml(data, srid = nil, flatten_collection = false)
      new_geometry(::Charta::GML.new(data, srid).to_ewkt, nil, nil, flatten_collection)
    end

    def from_kml(data, flatten_collection = false)
      new_geometry(::Charta::KML.new(data).to_ewkt, nil, nil, flatten_collection)
    end

    def from_geojson(data, srid = nil)
      new_geometry(::Charta::GeoJSON.new(data, srid).to_ewkt)
    end

    def new_collection(geometries)
      geometries.is_a?(Array) && geometries.any? ? new_geometry(Charta.select_value("SELECT ST_AsEWKT(ST_Collect(ARRAY[#{geometries.collect { |geo| geo[:shape].geom }.join(',')}]))"), nil, nil, false, geometries) : Charta.empty_geometry
    end
  end
end
