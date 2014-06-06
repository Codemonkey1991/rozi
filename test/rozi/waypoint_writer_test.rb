
module Rozi

  class WaypointWriterTest < Minitest::Test
    def setup
      @subject = WaypointWriter.new()
    end

    def test_write
      waypoints = []
      waypoints << Waypoint.new(
        name: "Test", latitude: 60.872030, longitude: 12.049732
      )
      waypoints << Waypoint.new(
        name: "Test 2", latitude: 61.872030, longitude: 12.049732
      )
      waypoints << Waypoint.new(
        name: "Test 3", latitude: 60.872030, longitude: 13.049732
      )

      file = StringIO.new()

      @subject.write(waypoints, file)

      expected_output = <<-TEXT.chomp
OziExplorer Waypoint File Version 1.1
WGS 84
Reserved 2

-1,Test,60.872030,12.049732,,3,1,4,0,65535,,0,,,-777,6,0,17
-1,Test 2,61.872030,12.049732,,3,1,4,0,65535,,0,,,-777,6,0,17
-1,Test 3,60.872030,13.049732,,3,1,4,0,65535,,0,,,-777,6,0,17
      TEXT
    end

    def test_waypoint_to_text
      wpt = Waypoint.new(name: "test")

      assert_equal(
        "-1,test,0.000000,0.000000,,3,1,4,0,65535,,0,,,-777,6,0,17",
        @subject.waypoint_to_text(wpt)
      )

      wpt = Waypoint.new(name: "test", symbol: :house)

      assert_equal(
        "-1,test,0.000000,0.000000,,10,1,4,0,65535,,0,,,-777,6,0,17",
        @subject.waypoint_to_text(wpt)
      )

      wpt = Waypoint.new(name: "test", description: "æøå, ÆØÅ")

      assert_equal(
        "-1,test,0.000000,0.000000,,3,1,4,0,65535,æøåÑ ÆØÅ,0,,,-777,6,0,17",
        @subject.waypoint_to_text(wpt)
      )
    end
  end

end
