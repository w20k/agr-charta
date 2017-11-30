require 'json'
require 'rgeo/geo_json'
require 'rgeo/svg' # integrated lib for now

module Charta
  # Represents a Geometry with SRID
  class Geometry
    def initialize(feature, properties = {})
      self.feature = feature
      @properties = properties
    end

    def inspect
      "<#{self.class.name}(#{to_ewkt})>"
    end

    # Returns the type of the geometry as a string. Example: point,
    # multi_polygon, geometry_collection...
    def type
      Charta.underscore(feature.geometry_type.type_name).to_sym
    end

    # Returns the type of the geometry as a string. EG: 'ST_Linestring', 'ST_Polygon',
    # 'ST_MultiPolygon' etc. This function differs from GeometryType(geometry)
    # in the case of the string and ST in front that is returned, as well as the fact
    # that it will not indicate whether the geometry is measured.
    def collection?
      feature.geometry_type == RGeo::Feature::GeometryCollection
    end

    # Return the spatial reference identifier for the ST_Geometry
    def srid
      feature.srid.to_i
    end

    # Returns the underlaying object managed by Charta: the RGeo feature
    def to_rgeo
      feature
    end

    # Returns the Well-Known Text (WKT) representation of the geometry/geography
    # without SRID metadata
    def to_text
      feature.as_text.match(/\ASRID=.*;(.*)/)[1]
    end
    alias as_text to_text
    alias to_wkt to_text

    # Returns EWKT: WKT with its SRID
    def to_ewkt
      Charta.generate_ewkt(feature).to_s
    end
    alias to_s to_ewkt

    def ewkt
      puts 'DEPRECATION WARNING: Charta::Geometry.ewkt is deprecated. Please use Charta::Geometry.to_ewkt instead'
      to_ewkt
    end

    #  Return the Well-Known Binary (WKB) representation of the geometry with SRID meta data.
    def to_binary
      generator = RGeo::WKRep::WKBGenerator.new(tag_format: :ewkbt, emit_ewkbt_srid: true)
      generator.generate(feature)
    end
    alias to_ewkb to_binary

    # Pas bien compris le fonctionnement
    def to_svg(options = {})
      svg = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1"'
      { preserve_aspect_ratio: 'xMidYMid meet',
        width: 180, height: 180,
        view_box: bounding_box.svg_view_box.join(' ') }.merge(options).each do |attr, value|
        svg << " #{Charta.camelcase(attr.to_s, :lower)}=\"#{value}\""
      end
      svg << "><path d=\"#{to_svg_path}\"/></svg>"
      svg
    end

    # Return the geometry as Scalar Vector Graphics (SVG) path data.
    def to_svg_path
      RGeo::SVG.encode(feature)
    end

    # Return the geometry as a Geometry Javascript Object Notation (GeoJSON) element.
    def to_geojson
      to_json_object.to_json
    end
    alias to_json to_geojson

    # Returns object in JSON (Hash)
    def to_json_object
      RGeo::GeoJSON.encode(feature)
    end

    # Test if the other measure is equal to self
    def ==(other)
      other_geometry = Charta.new_geometry(other).transform(srid)
      return true if empty? && other_geometry.empty?
      return inspect == other_geometry.inspect if collection? && other_geometry.collection?
      feature.equals?(other_geometry.feature)
    end

    # Test if the other measure is equal to self
    def !=(other)
      other_geometry = Charta.new_geometry(other).transform(srid)
      return true if empty? && other_geometry.empty?
      return inspect == other_geometry.inspect if collection? && other_geometry.collection?
      !feature.equals?(other_geometry.feature)
    end

    # Returns true if Geometry is a Surface
    def surface?
      [RGeo::Feature::Polygon, RGeo::Feature::MultiPolygon].include? feature.geometry_type
    end

    # Returns area in unit corresponding to the SRS
    def area
      surface? ? feature.area : 0
    end

    # Returns true if this Geometry is an empty geometrycollection, polygon,
    # point etc.
    def empty?
      feature.is_empty?
    end
    alias blank? empty?

    # Computes the geometric center of a geometry, or equivalently, the center
    # of mass of the geometry as a POINT.
    def centroid
      return nil unless surface? && !feature.is_empty?
      point = feature.centroid
      [point.y, point.x]
    end

    # Returns a POINT guaranteed to lie on the surface.
    def point_on_surface
      return nil unless surface?
      point = feature.point_on_surface
      [point.y, point.x]
    end

    def convert_to(new_type)
      case new_type
      when type then self
      when :multi_point then flatten_multi(:point)
      when :multi_line_string then flatten_multi(:line_string)
      when :multi_polygon then flatten_multi(:polygon)
      end
    end

    def flatten_multi(as_type)
      items = []
      as_multi_type = "multi_#{as_type}".to_sym
      if type == as_type
        items << feature
      elsif type == :geometry_collection
        feature.each do |geom|
          type_name = Charta.underscore(geom.geometry_type.type_name).to_sym
          if type_name == as_type
            items << geom
          elsif type_name == as_multi_type
            geom.each do |item|
              items << item
            end
          end
        end
      end
      Charta.new_geometry(feature.factory.send(as_multi_type, items))
    end

    # Returns a new geometry with the coordinates converted into the new SRS
    def transform(new_srid)
      return self if new_srid == srid
      raise 'Proj is not supported. Cannot tranform' unless RGeo::CoordSys::Proj4.supported?
      new_srid = Charta::SRS[new_srid] || new_srid
      database = self.class.srs_database
      new_proj_entry = database.get(new_srid)
      raise "Cannot find proj for SRID: #{new_srid}" if new_proj_entry.nil?
      new_feature = RGeo::CoordSys::Proj4.transform(
        database.get(srid).proj4,
        feature,
        new_proj_entry.proj4,
        self.class.factory(new_srid)
      )
      generator = RGeo::WKRep::WKTGenerator.new(tag_format: :ewkt, emit_ewkt_srid: true)
      Charta.new_geometry(generator.generate(new_feature))
    end

    # Produces buffer
    def buffer(radius)
      feature.buffer(radius)
    end

    def merge(other)
      other_geometry = Charta.new_geometry(other).transform(srid)
      feature.union(other_geometry.feature)
    end
    alias + merge

    def intersection(other)
      other_geometry = Charta.new_geometry(other).transform(srid)
      feature.intersection(other_geometry.feature)
    end

    def difference(other)
      other_geometry = Charta.new_geometry(other).transform(srid)
      feature.difference(other_geometry.feature)
    end
    alias - difference

    def bounding_box
      unless defined? @bounding_box
        bbox = RGeo::Cartesian::BoundingBox.create_from_geometry(feature)
        instance_variable_set('@x_min', bbox.min_x || 0)
        instance_variable_set('@y_min', bbox.min_y || 0)
        instance_variable_set('@x_max', bbox.max_x || 0)
        instance_variable_set('@y_max', bbox.max_y || 0)
        @bounding_box = BoundingBox.new(@y_min, @x_min, @y_max, @x_max)
      end
      @bounding_box
    end

    %i[x_min y_min x_max y_max].each do |name|
      define_method name do
        bounding_box.send(name)
      end
    end

    def find_srid(name_or_srid)
      Charta.find_srid(name_or_srid)
    end

    # TODO: Manage YAML domain type to ensure maintainability of YAML
    # serialization in time.
    def feature
      unless defined? @feature
        if defined? @ewkt
          @feature = ::Charta::Geometry.from_ewkt(@ewkt)
          @properties = @options.dup if @options
        else
          raise StandardError, 'Invalid geometry (no feature, no EWKT)'
        end
      end
      @feature.dup
    end

    def feature=(new_feature)
      raise ArgumentError, "Feature can't be nil" if new_feature.nil?
      @feature = new_feature
    end

    def to_json_feature(properties = {})
      { type: 'Feature', properties: properties, geometry: to_json_object }
    end

    class << self
      def srs_database
        @srs_database ||= RGeo::CoordSys::SRSDatabase::Proj4Data.new('epsg', authority: 'EPSG', cache: true)
      end

      def factory(srid = 4326)
        return projected_factory(srid) if srid.to_i == 4326
        geos_factory(srid)
      end

      def feature(ewkt_or_rgeo)
        return from_rgeo(ewkt_or_rgeo) if ewkt_or_rgeo.is_a? RGeo::Feature::Instance
        from_ewkt(ewkt_or_rgeo)
      end

      def from_rgeo(rgeo)
        srid = rgeo.srid
        RGeo::Feature.cast(rgeo, factory: Geometry.factory(srid))
      end

      def from_ewkt(ewkt)
        # Cleans empty geometries
        ewkt.gsub!(/(GEOMETRYCOLLECTION|GEOMETRY|((MULTI)?(POINT|LINESTRING|POLYGON)))\(\)/, '\1 EMPTY')
        srs = ewkt.split(/[\=\;]+/)[0..1]
        srid = nil
        srid = srs[1] if srs[0] =~ /srid/i
        srid ||= 4326
        factory(srid).parse_wkt(ewkt)
      rescue RGeo::Error::ParseError => e
        raise "Invalid EWKT (#{e.class.name}: #{e.message}): #{ewkt}"
      end

      private

      def geos_factory(srid)
        RGeo::Geos.factory(
          srid: srid,
          wkt_generator: {
            type_format: :ewkt,
            emit_ewkt_srid: true,
            convert_case: :upper
          },
          wkt_parser: {
            support_ewkt: true
          },
          wkb_generator:  {
            type_format: :ewkb,
            emit_ewkb_srid: true,
            hex_format: true
          },
          wkb_parser: {
            support_ewkb: true
          }
        )
      end

      def projected_factory(srid)
        proj4 = '+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs'
        RGeo::Geographic.projected_factory(
          srid: srid,
          wkt_generator: {
            type_format: :ewkt,
            emit_ewkt_srid: true,
            convert_case: :upper
          },
          wkt_parser: {
            support_ewkt: true
          },
          wkb_generator:  {
            type_format: :ewkb,
            emit_ewkb_srid: true,
            hex_format: true
          },
          wkb_parser: {
            support_ewkb: true
          },
          projection_srid: 6933,
          projection_proj4: proj4
        )
      end
    end
  end
end
