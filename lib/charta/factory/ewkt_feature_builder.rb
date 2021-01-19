# frozen_string_literal: true

module Charta
  module Factory
    class EwktFeatureBuilder
      # @param [String] ewkt EWKT representation of a feature
      # @return [RGeo::Feature::Instance]
      def from_ewkt(ewkt)
        if ewkt.to_s =~ /\A[[:space:]]*\z/
          raise ArgumentError.new("Invalid data: #{ewkt.inspect}")
        end

        Geometry.feature(ewkt)
      end
    end
  end
end
