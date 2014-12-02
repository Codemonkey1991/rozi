
require "stringio"

module RoziTestSuite
  class WriteWaypointsTest < TestCase
    def setup
      @subject = Rozi.method(:write_waypoints)
    end

    def test_basic_usage
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

      file = StringIO.new
      Rozi.expects(:open_file).returns(file)

      @subject.call(waypoints, "/x/y.wpt", datum: "WGS 84", version: "1.1")

      assert_equal(
        RoziTestSuite.read_test_data("expected_output_1.wpt"),
        file.string
      )
    end
  end

  class WaypointTest < TestCase
    def test_initialize
      wp = Rozi::Waypoint.new(number: 5, name: "Test point")

      assert_equal "Test point", wp.name
      assert_equal 5, wp.number

      assert_raises(ArgumentError) {
        # Invalid attribute "foo".
        wp = Rozi::Waypoint.new(foo: 123)
      }
    end

    def test_colors
      wp = Rozi::Waypoint.new()
      wp.expects(:interpret_color).twice.with(:foo).returns(:bar)

      wp.fg_color = :foo
      assert_equal :bar, wp.fg_color

      wp.bg_color = :foo
      assert_equal :bar, wp.bg_color
    end
  end

  class WaypointFileTest < TestCase
    def setup
      @sio = StringIO.new
      @subject = Rozi::WaypointFile.new(@sio)
    end

    def test_serialize_waypoint_file_properties
      m = Rozi::WaypointFileProperties.new

      assert_equal(
        "OziExplorer Waypoint File Version 1.1\n" +
        "WGS 84\n" +
        "Reserved 2\n",
        @subject.send(:serialize_waypoint_file_properties, m)
      )

      m = Rozi::WaypointFileProperties.new("Norge", "1.2")

      assert_equal(
        "OziExplorer Waypoint File Version 1.2\n" +
        "Norge\n" +
        "Reserved 2\n",
        @subject.send(:serialize_waypoint_file_properties, m)
      )
    end

    def test_serialize_waypoint
      wpt = Rozi::Waypoint.new(name: "test")

      assert_equal(
        "-1,test,0.000000,0.000000,,0,1,3,0,65535,,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )

      wpt = Rozi::Waypoint.new(name: "test", symbol: 4)

      assert_equal(
        "-1,test,0.000000,0.000000,,4,1,3,0,65535,,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )

      wpt = Rozi::Waypoint.new(name: "test", description: "æøå, ÆØÅ")

      assert_equal(
        "-1,test,0.000000,0.000000,,0,1,3,0,65535,æøåÑ ÆØÅ,0,,,-777,6,0,17",
        @subject.send(:serialize_waypoint, wpt)
      )
    end
  end
end
