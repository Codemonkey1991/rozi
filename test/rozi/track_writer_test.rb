
require "stringio"

module Rozi

  class TrackWriterTest < Minitest::Test
    def test_write
      point1 = mock()
      point1.expects(:to_a).returns([12.34, 56.78, 0, -777, 0, "", ""])

      point2 = mock()
      point2.expects(:to_a).returns([23.45, 67.89, 0, -777, 0, "", ""])

      track = mock()
      track.expects(:attributes).returns([2, 255, "foo, bar", 1, 0, 0, 0])
      track.expects(:points).twice.returns([point1, point2])

      file = StringIO.new()

      subject = TrackWriter.new()
      subject.write(track, file)

      file.rewind()

      assert_equal(<<-TRACK, file.read())
OziExplorer Track Point File Version 2.1
WGS 84
Altitude is in Feet
Reserved 3
0,2,255,fooÑ bar,1,0,0,0
2
  12.340000,56.780000,0,-777.0,0.0000000,,
  23.450000,67.890000,0,-777.0,0.0000000,,
      TRACK
    end

    def test_track_attributes_to_text
      subject = TrackWriter.new()

      track = mock()
      track.expects(:attributes).returns([2, 0, "foo, bar", 1, 0, 0, 0])

      assert_equal(
        "0,2,0,fooÑ bar,1,0,0,0",
        subject.track_attributes_to_text(track)
      )
    end

    def test_track_point_to_text
      subject = TrackWriter.new()

      point = mock()
      point.expects(:to_a).returns([12.34, 56.78, 0, -777, 0, "", ""])

      assert_equal(
        "  12.340000,56.780000,0,-777.0,0.0000000,,",
        subject.track_point_to_text(point)
      )
    end
  end

end
