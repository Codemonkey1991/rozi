
module Rozi
  class WaypointTest < Minitest::Test
    def test_initialize
      wp = Waypoint.new(number: 5, name: "Test point")

      assert_equal "Test point", wp.name
      assert_equal 5, wp.number

      assert_raises(ArgumentError) {
        # Invalid attribute "foo".
        wp = Waypoint.new(foo: 123)
      }
    end

    def test_colors
      wp = Waypoint.new()
      wp.expects(:interpret_color).twice.with(:foo).returns(:bar)

      wp.fg_color = :foo
      assert_equal :bar, wp.fg_color

      wp.bg_color = :foo
      assert_equal :bar, wp.bg_color
    end
  end

  class WaypointFileTest < Minitest::Test
    def setup
      @sio = StringIO.new
      @subject = WaypointFile.new(@sio)
    end

    def test_basic_writing
      RoziTestSuite.temp_file_path do |file_path|
        wptfile = WaypointFile.open(file_path, "w")

        metadata = WaypointMetadata.new(datum: "WGS 84", version: "1.1")

        waypoints = [
          Rozi::Waypoint.new(
            latitude: 59.91273, longitude: 10.74609, name: "OSLO"
          ),
          Rozi::Waypoint.new(
            latitude: 60.39358, longitude: 5.32476, name: "BERGEN"
          ),
          Rozi::Waypoint.new(
            latitude: 62.56749, longitude: 7.68709, name: "ÅNDALSNES"
          )
        ]

        wptfile.write_metadata(metadata)
        wptfile.write(waypoints)
        wptfile.close

        assert_equal(
          RoziTestSuite.read_test_data("expected_output_1.wpt"),
          File.read(file_path, mode: "rb")
        )
      end
    end

    def test_serialize_metadata
      m = WaypointMetadata.new

      assert_equal(
        "OziExplorer Waypoint File Version 1.1\n" +
        "WGS 84\n" +
        "Reserved 2\n",
        @subject.send(:serialize_metadata, m)
      )

      m = WaypointMetadata.new("Norge", "1.2")

      assert_equal(
        "OziExplorer Waypoint File Version 1.2\n" +
        "Norge\n" +
        "Reserved 2\n",
        @subject.send(:serialize_metadata, m)
      )
    end

    def test_serialize_waypoint
      wpt = Waypoint.new(name: "test")

      assert_equal(
        "-1,test,0.000000,0.000000,,0,1,3,0,65535,,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )

      wpt = Waypoint.new(name: "test", symbol: 4)

      assert_equal(
        "-1,test,0.000000,0.000000,,4,1,3,0,65535,,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )

      wpt = Waypoint.new(name: "test", description: "æøå, ÆØÅ")

      assert_equal(
        "-1,test,0.000000,0.000000,,0,1,3,0,65535,æøåÑ ÆØÅ,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )
    end
  end
end
