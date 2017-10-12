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

unless RGeo::CoordSys::Proj4.supported?
  puts "Proj4 is not supported. Some actions won't work"
end

# Charta aims to supply easy geom/geog tools
module Charta
  SRS = {
    WGS84: 4326,
    CRS84: 4326,
    RGF93: 2143
  }.freeze

  class << self
    def new_feature(coordinates, srs = nil, format = nil, _flatten_collection = true, _options = {})
      geom_ewkt = nil
      if coordinates.is_a?(RGeo::Feature::Instance)
        return Geometry.feature(coordinates)
      elsif coordinates.is_a?(::Charta::Geometry)
        return coordinates
      elsif coordinates.to_s =~ /\A[[:space:]]*\z/
        geom_ewkt = empty_geometry(srs).to_ewkt
      elsif coordinates.is_a?(Hash) || (coordinates.is_a?(String) && ::Charta::GeoJSON.valid?(coordinates)) # GeoJSON
        srid = srs ? find_srid(srs) : :WGS84
        geom_ewkt = ::Charta::GeoJSON.new(coordinates, srid).to_ewkt
      elsif coordinates.is_a?(String)
        geom_ewkt = if coordinates =~ /\A[A-F0-9]+\z/ # WKB
                      if srs && srid = find_srid(srs)
                        generate_ewkt RGeo::Geos.factory(srid: srid).parse_wkb(coordinates)
                      else
                        generate_ewkt Geometry.factory.parse_wkb(coordinates)
                      end
                    elsif format == 'gml' && ::Charta::GML.valid?(coordinates)
                      # required format 'cause kml geometries return empty instead of failing
                      ::Charta::GML.new(coordinates, srid).to_ewkt
                    elsif format == 'kml' && ::Charta::KML.valid?(coordinates)
                      ::Charta::KML.new(coordinates).to_ewkt
                    elsif coordinates =~ /^SRID\=\d+\;/i
                      if feature = Geometry.feature(coordinates)
                        generate_ewkt feature
                      else
                        Charta::GeometryCollection.empty.feature
                      end
                    else # WKT expected
                      if srs && srid = find_srid(srs)
                        begin
                          f = RGeo::Geos.factory(srid: srid).parse_wkt(coordinates)
                        rescue RGeo::Error::ParseError => e
                          raise "Invalid EWKT (#{e.message}): #{coordinates}"
                        end
                        generate_ewkt f
                      else
                        generate_ewkt Geometry.feature(coordinates)
                      end
                    end
      else # Default for RGeo
        geom_ewkt = generate_ewkt coordinates
      end
      if geom_ewkt.to_s =~ /\A[[:space:]]*\z/
        raise ArgumentError, "Invalid data: coordinates=#{coordinates.inspect}, srid=#{srid.inspect}"
      end
      Geometry.feature(geom_ewkt)
    end

    def new_geometry(coordinates, _srs = nil, _format = nil, _flatten_collection = true, _options = {})
      return coordinates if coordinates.is_a?(::Charta::Geometry)
      feature = Charta.new_feature(coordinates, srs, format, _flatten_collection, _options)
      type = feature.geometry_type
      geom = case type
             when RGeo::Feature::Point then
               Point.new(feature)
             when RGeo::Feature::LineString then
               LineString.new(feature)
             when RGeo::Feature::Polygon then
               Polygon.new(feature)
             when RGeo::Feature::MultiPolygon then
               MultiPolygon.new(feature)
             when RGeo::Feature::GeometryCollection then
               GeometryCollection.new(feature)
             else
               Geometry.new(feature)
             end
      geom
    end

    def new_point(lat, lon, srid = 4326)
      feature = Charta.new_feature("SRID=#{srid};POINT(#{lon} #{lat})")
      Point.new(feature)
    end

    def make_line(points, options = {})
      options[:srid] ||= new_geometry(points.first).srid if points.any?
      options[:srid] ||= 4326

      ewkt = "SRID=#{options[:srid]};LINESTRING(" + points.map { |wkt| p = new_geometry(wkt); "#{p.x} #{p.y}" }.join(', ') + ')'
      new_geometry(ewkt)
    end

    def empty_geometry(srid = :WGS84)
      GeometryCollection.empty(srid)
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
        x = srname_or_srid.split(':').last.upcase.to_sym
        SRS[x] || x
      elsif srname_or_srid.to_s =~ /\AEPSG::?(\d{4,5})\z/
        srname_or_srid.split(':').last
      elsif srname_or_srid.to_s =~ /\A\d+\z/
        srname_or_srid.to_i
      else
        SRS[srname_or_srid] || srname_or_srid
      end
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

    # Utility methods

    def underscore(text)
      text.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
    end

    def camelcase(text, first_letter = :upper)
      ret = text.split(/[_\-]+/).map { |word| word[0..0].upcase + word[1..-1].downcase }.join
      ret = text[0..0].downcase + text[1..-1] if first_letter == :lower
      ret
    end
  end
end
