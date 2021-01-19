require 'test_helper'
require 'yaml'

module Charta
  class GeometryTest < Charta::Test
    def test_different_EWKT_input_formats
      samples = ['POINT(6 10)',
                 'LINESTRING(3 4,10 50,20 25)',
                 'POLYGON((1 1,5 1,5 5,1 5,1 1))',
                 'MULTIPOINT((3.5 5.6), (4.8 10.5))',
                 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))',
                 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))',
                 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))',
                 # 'POINT ZM (1 1 5 60)',
                 # 'POINT M (1 1 80)',
                 'POINT EMPTY',
                 'MULTIPOLYGON EMPTY']

      samples.each_with_index do |sample, index|
        geom1 = Charta.new_geometry(sample, :WGS84)
        geom2 = Charta.new_geometry("SRID=4326;#{sample}")

        assert_equal geom1.to_ewkt, geom2.to_ewkt

        assert_equal geom1.srid, geom2.srid

        assert geom1 == geom2 if index <= 5
        assert geom1.area
      end

      assert Charta.empty_geometry.empty?
    end

    def test_srid_in_ewkt
      geom = Charta.new_geometry('SRID=2154;MULTIPOLYGON(((7.40679681301117 48.1167274678089,7.40882456302643 48.1158768860692,7.40882456302643 48.1158679325024,7.40678608417511 48.1167220957579,7.40679681301117 48.1167274678089)))')
      assert_equal 2154, geom.srid
      assert_equal '2154', geom.to_ewkt.split(/[\=\;]+/)[1], geom.to_ewkt
      geom2 = Charta.new_geometry(geom)
      assert_equal 2154, geom2.srid
      assert_equal geom, geom2

      geom = Charta.new_geometry('MULTIPOLYGON(((7.40679681301117 48.1167274678089,7.40882456302643 48.1158768860692,7.40882456302643 48.1158679325024,7.40678608417511 48.1167220957579,7.40679681301117 48.1167274678089)))')
      assert_equal 4326, geom.srid
      assert_equal '4326', geom.to_ewkt.split(/[\=\;]+/)[1], geom.to_ewkt
    end

    def test_type
      geo = Charta.new_geometry('SRID=4326;MULTIPOLYGON(((7.40679681301117 48.1167274678089,7.40882456302643 48.1158768860692,7.40882456302643 48.1158679325024,7.40678608417511 48.1167220957579,7.40679681301117 48.1167274678089)))')
      assert_equal :multi_polygon, geo.type
    end

    def test_different_GeoJSON_input_formats
      samples = []
      samples << {
        'type' => 'FeatureCollection',
        'features' => []
      }

      # http://geojson.org/geojson-spec.html#examples
      samples << '{ "type": "FeatureCollection", "features": [   { "type": "Feature",     "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},     "properties": {"prop0": "value0"}     },   { "type": "Feature",     "geometry": {       "type": "LineString",       "coordinates": [         [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]         ]       },     "properties": {       "prop0": "value0",       "prop1": 0.0       }     },   { "type": "Feature",      "geometry": {        "type": "Polygon",        "coordinates": [          [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],            [100.0, 1.0], [100.0, 0.0] ]          ]      },      "properties": {        "prop0": "value0",        "prop1": {"this": "that"}        }      }    ]  }'

      # http://geojson.org/geojson-spec.html#examples
      samples << '{ "type": "FeatureCollection", "features": [ { "type": "Feature", "geometry": {"type": "Point", "coordinates": [102.0, 0.5]}, "properties": {"prop0": "value0"} }, { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [ [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0] ] }, "properties": { "prop0": "value0", "prop1": 0.0 } }, { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [ [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0], [100.0, 1.0], [100.0, 0.0] ] ] }, "properties": { "prop0": "value0", "prop1": {"this": "that"} } } ] }'

      # http://geojson.org/geojson-spec.html#examples
      samples << '{ "type": "FeatureCollection",
    "features": [
      { "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [102.0, 0.5]},
        "properties": {"prop0": "value0"}
      },
      { "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [102.0, 0.0], [103.0, 1.0], [104.0, 0.0], [105.0, 1.0]
            ]
          },
        "properties": {
          "prop0": "value0",
          "prop1": 0.0
          }
      },
      { "type": "Feature",
         "geometry": {
           "type": "Polygon",
           "coordinates": [
             [ [100.0, 0.0], [101.0, 0.0], [101.0, 1.0],
               [100.0, 1.0], [100.0, 0.0] ]
             ]
         },
         "properties": {
           "prop0": "value0",
           "prop1": {"this": "that"}
           }
      }
       ]
     }'

      samples.each_with_index do |sample, _index|
        geom = Charta.new_geometry(sample)
        assert_equal 4326, geom.srid
      end
    end

    def test_GML_fragment_input
      fragment = "<gml:Polygon>
        <gml:outerBoundaryIs>
        <gml:LinearRing>
        <gml:coordinates>
            407307.0555,6529551.3646 407260.5151,6529576.8458 407239.0404,6529537.6039 407181.6257,6529572.7935 407176.7528,6529565.4424 407180.6996,6529574.6456 407169.4221,6529559.5514 407162.0488,6529542.6713 407156.6494,6529533.9075 407152.4748,6529529.1499
        407146.7973,6529526.2284 407140.9526,6529525.978 407135.8596,6529528.9828 407133.7721,6529534.2413 407131.9353,6529538.1645 407130.1819,6529539.5 407126.3414,6529540.0008 407120.1626,6529539.5 407115.3201,6529537.914 407113.2328,6529533.3232
        407113.2328,6529527.3135 407116.8989,6529509.5777 407125.4918,6529477.0837 407136.0907,6529442.9418 407188.5401,6529451.5411 407217.9593,6529454.3293 407238.3643,6529497.2081 407242.6406,6529504.6893 407248.472,6529506.1467 407283.059,6529496.4856
        407275.5885,6529480.296 407248.169,6529430.302 407273.051,6529421.056 407279.5092,6529417.7912 407243.4074,6529345.4337 407235.3894,6529329.7666 407240.0713,6529321.1407 407250.6157,6529304.443 407258.4157,6529292.4747 407266.15,6529310.1125
        407292.4624,6529364.7683 407330.3168,6529443.1431 407358.0462,6529499.9032 407341.5258,6529505.4083 407299.5688,6529520.9968 407296.1057,6529523.4567 407296.1057,6529526.7364 407307.0555,6529551.3646
        </gml:coordinates>
        </gml:LinearRing>
        </gml:outerBoundaryIs>
    </gml:Polygon>"

      geometries = ::Charta.from_gml(fragment, 2154)
      geom = Charta.new_geometry(geometries).transform(4326)
      assert_equal 4326, geom.srid
    end

    def test_different_GML_input_formats
      xml = File.read fixture_files_path.join('map.gml')
      assert ::Charta::GML.valid?(xml), 'GML should be valid'
      geom = Charta.new_geometry(xml, nil, 'gml', false)
      assert_equal 4326, geom.srid
    end

    def test_different_KML_input_formats
      xml = File.read fixture_files_path.join('map.kml')
      assert ::Charta::KML.valid?(xml), 'KML should be valid'
      geom = Charta.new_geometry(xml, nil, 'kml', false)
      assert_equal 4326, geom.srid
    end

    def test_three_dimensional_json_support
      json = File.read fixture_files_path.join('map_3d.json')
      Charta.new_geometry(json)
    end

    def test_comparison_and_methods_between_2_geometries
      samples = ['POINT(6 10)',
                 'LINESTRING(3 4,10 50,20 25)',
                 'POLYGON((1 1,5 1,5 5,1 5,1 1))',
                 'MULTIPOINT((3.5 5.6), (4.8 10.5))',
                 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))',
                 'MULTIPOLYGON(((7.40679681301117 48.1167274678089,7.40882456302643 48.1158768860692,7.40882456302643 48.1158679325024,7.40678608417511 48.1167220957579,7.40679681301117 48.1167274678089)))',
                 'GEOMETRYCOLLECTION(POLYGON((7.40882456302643 48.1158768860692,7.40679681301117 48.1167274678089,7.40678608417511 48.1167220957579,7.40882456302643 48.1158679325024,7.40882456302643 48.1158768860692)),POINT(4 6),LINESTRING(4 6,7 10))',
                 'POINT EMPTY',
                 'MULTIPOLYGON EMPTY'].collect do |ewkt|
        Charta.new_geometry("SRID=4326;#{ewkt}")
      end
      last = samples.count - 1
      samples.each_with_index do |geom1, i|
        (i..last).each do |j|
          geom2 = samples[j]
          # puts "##{i} #{geom1.to_ewkt.yellow} ~ ##{j} #{geom2.to_ewkt.blue}"
          unless geom1.collection? && geom2.collection?
            if j == i || (geom1.empty? && geom2.empty?)
              assert_equal geom1, geom2, "#{geom1.to_ewkt} and #{geom2.to_ewkt} should be equal"
            else
              assert geom1 != geom2, "#{geom1.to_ewkt} and #{geom2.to_ewkt} should be different"
            end
          end
          geom1.merge(geom2)
          geom1.intersection(geom2)
          geom1.difference(geom2)
        end
      end
    end

    def test_class_cast
      samples = {
        'Point' => 'POINT(6 10)',
        'LineString' => 'LINESTRING(3 4,10 50,20 25)',
        'Polygon' => 'POLYGON((1 1,5 1,5 5,1 5,1 1))',
        'MultiPolygon' => 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))',
        'GeometryCollection' => 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))'
      }
      samples.each do |class_name, ewkt|
        assert_equal 'Charta::' + class_name, Charta.new_geometry(ewkt).class.name
      end
    end

    def test_retrieval_of_a_GeometryCollection_as_a_valid_geojson_feature_collection
      sample = 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))'
      expected_result = {
        'type' => 'GeometryCollection',
        'geometries' => [
          { 'type' => 'Point', 'coordinates' => [4.0, 6.0] },
          { 'type' => 'LineString', 'coordinates' => [[4.0, 6.0], [7, 10]] }
        ]
      }

      geom = Charta.new_geometry(sample)
      json_object = geom.to_json_object

      assert_equal Hash, json_object.class, 'JSON object should be a Hash'
      assert json_object.key?('type'), "JSON object should include the 'type' key"
      assert_equal 'GeometryCollection', json_object['type'], 'JSON object should be a GeometryCollection'

      assert_equal expected_result, json_object
    end

    def test_transformation
      geom = Charta.new_geometry('POINT(-0.54413 44.818208)', 4326)
      assert_equal 4326, geom.srid
      lambert = geom.transform(2154)
      assert lambert
      assert_equal 2154, lambert.srid
      assert_equal 419_912.576891, lambert.x.round(6)
      assert_equal 6_419_514.472132, lambert.y.round(6)
      back = lambert.transform(4326)
      assert back
      assert_equal 4326, back.srid
      assert_equal geom.x, back.x.round(6)
      assert_equal geom.y, back.y.round(6)
    end

    def test_export_format
      samples = ['POINT(6 10)',
                 'LINESTRING(3 4,10 50,20 25)',
                 'POLYGON((1 1,5 1,5 5,1 5,1 1))',
                 'MULTIPOINT((3.5 5.6), (4.8 10.5))',
                 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))',
                 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))',
                 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))',
                 # 'POINT ZM (1 1 5 60)',
                 # 'POINT M (1 1 80)',
                 'POINT EMPTY',
                 'MULTIPOLYGON EMPTY']
      samples.each do |s|
        geom = Charta.new_geometry(s, 4326)
        assert geom.to_wkt
        assert geom.to_ewkt
        assert geom.to_ewkb
        assert geom.to_svg
      end
    end

    def test_area
      data = '{
                "type": "Feature",
                "properties": {},
                "geometry": {
                  "type": "Polygon",
                  "coordinates": [
                    [
                      [
                        2.2214162349700928,
                        45.89087440253303
                      ],
                      [
                        2.220107316970825,
                        45.88891786700034
                      ],
                      [
                        2.2223711013793945,
                        45.88809640024204
                      ],
                      [
                        2.2246885299682617,
                        45.88996335257688
                      ],
                      [
                        2.223111391067505,
                        45.8900679000522
                      ],
                      [
                        2.2214162349700928,
                        45.89087440253303
                      ]
                    ]
                  ]
                }
              }'
      geom = Charta.new_geometry(data)
      assert_equal 4326, geom.srid
      assert_equal 5.448, (geom.area / 10_000).round(3)
    end

    def test_wkt_extraction_from_ewkt
      wkt = 'MULTIPOLYGON (((-0.900063514709473 44.2905272467262, -0.900835990905762 44.2907115613672, -0.902767181396484 44.2870251586485, -0.902037620544434 44.2867793902409, -0.900063514709473 44.2905272467262)))'
      ewkt = "SRID=4326;#{wkt}"

      geom = Charta.new_geometry(ewkt)

      assert_equal wkt, geom.to_text
    end

    def test_nil_feature
      assert_raises ArgumentError do
        Charta::Geometry.new(nil)
      end

      nil_geometry = Charta.new_geometry(nil)
      assert nil_geometry.empty?
      assert nil_geometry.inspect

      assert_raises ArgumentError do
        nil_geometry.feature = nil
      end
    end

    def test_yaml_serialization
      yaml = <<~YAML
        ---
        !ruby/object:Charta::MultiPolygon
        ewkt: SRID=4326;MULTIPOLYGON(((1.64468269737984 49.4801478441764,1.64465846208501 49.4800879855142,1.64451455635114 49.4798795855698,1.64434333980203 49.4795066520487,1.64349432130535 49.4777636867183,1.64310806699683 49.47696228419,1.64329247554595 49.4769248156496,1.64577012185865 49.4763689056835,1.64593430444977 49.4767522589754,1.6468489005132 49.4785456945119,1.6468506318855 49.478549102676,1.64679688540217 49.4785941662853,1.64635829118453 49.4788544052356,1.64622114404453 49.4789337375618,1.64605021476746 49.4789997404691,1.64572298526764 49.4792123497544,1.6454403726604 49.4794945421142,1.64515435695648 49.4797246994857,1.64488613605499 49.479975644337,1.64468269737984 49.4801478441764)))
        options: {}
      YAML
      object = YAML.safe_load(yaml, permitted_classes: ['Charta::MultiPolygon'])

      object2 = YAML.safe_load(object.to_yaml, permitted_classes: ['Charta::MultiPolygon'])

      assert_equal object, object2
    end
  end
end
