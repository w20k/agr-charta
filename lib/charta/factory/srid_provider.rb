# frozen_string_literal: true

module Charta
  module Factory
    class SridProvider
      SRS = {
        WGS84: 4326,
        CRS84: 4326,
        RGF93: 2143
      }.freeze

      class << self
        def build
          new(SRS)
        end
      end

      def initialize(srs)
        @srs = srs
      end

      def find(srname_or_srid)
        if srname_or_srid.to_s =~ /\Aurn:ogc:def:crs:.*\z/
          x = srname_or_srid.split(':').last.upcase.to_sym
          @srs[x] || x
        elsif srname_or_srid.to_s =~ /\AEPSG::?(\d{4,5})\z/
          srname_or_srid.split(':').last
        elsif srname_or_srid.to_s =~ /\A\d+\z/
          srname_or_srid.to_i
        else
          @srs[srname_or_srid] || srname_or_srid
        end
      end
    end
  end
end