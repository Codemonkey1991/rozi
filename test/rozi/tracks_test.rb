
require "stringio"

module RoziTestSuite
  class WriteTrackTest < Minitest::Test
    def setup
      @subject = Rozi.method(:write_track)
    end

    def test_basic_usage
      expected_output = RoziTestSuite.read_test_data("expected_output_1.plt")

      track_points = [
        Rozi::TrackPoint.new(59.912730, 10.746090),
        Rozi::TrackPoint.new(60.393580, 5.324760),
        Rozi::TrackPoint.new(62.567490, 7.687090),
      ]

      file = StringIO.new
      Rozi.expects(:open_file).returns(file)

      @subject.call(
        track_points, "/some/file/path.plt", description: "foo, bar"
      )

      assert_equal expected_output, file.string
    end
  end

  class TrackPropertiesTest < Minitest::Test
    def setup
      @subject = Rozi::TrackProperties.new
    end

    def test_color
      @subject.expects(:interpret_color).with(:foo).returns(:bar)

      @subject.color = :foo

      assert_equal :bar, @subject.color
    end

    def test_set_datum
      @subject.datum = "Norsk"
      assert_equal "Norsk", @subject.datum
    end

    def test_set_invalid_datum
      assert_raises(ArgumentError) {
        @subject.datum = "Foo"
      }
    end
  end

  class TrackFileTest < Minitest::Test
    def setup
      @subject = Rozi::TrackFile.new(nil)
    end

    def test_serialize_track_attributes
      expected_output = <<-TEXT.gsub(/^ {8}/, "")
        OziExplorer Track Point File Version 2.1
        Norsk
        Altitude is in Feet
        Reserved 3
        0,5,12345,WellÑ this is fun!,2,5,1,54321
        0
      TEXT

      props = Rozi::TrackProperties.new(
        datum: "Norsk",
        line_width: 5,
        color: 12345,
        description: "Well, this is fun!",
        skip_value: 2,
        type: 5,
        fill_style: 1,
        fill_color: 54321
      )

      assert_equal(
        expected_output,
        @subject.send(:serialize_track_properties, props)
      )
    end

    def test_serialize_track_point
      expected_output = "  12.340000,45.560000,1,46.0,123.0000000,foo,bar"

      track_point = Rozi::TrackPoint.new(
        latitude: 12.34, longitude: 45.56,
        break: true,
        altitude: 46,
        date: 123,
        date_string: "foo",
        time_string: "bar"
      )

      assert_equal(
        expected_output,
        @subject.send(:serialize_track_point, track_point)
      )
    end
  end
end
