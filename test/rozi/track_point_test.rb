
require "rozi/track_point"
require "minitest/autorun"

module Rozi

  class TrackPointTest < Minitest::Test
    def test_initialize_defaults
      point = TrackPoint.new()

      TrackPoint::DEFAULTS.each_pair { |key, value|
        assert_equal value, point.send(key)
      }
    end

    def test_initialize_with_args
      attrs = {latitude: 123.45, longitude: 567.89, break: 1}
      point = TrackPoint.new(attrs)

      attrs.each_pair { |key, value|
        assert_equal value, point.send(key)
      }
    end

    def test_to_a
      point = TrackPoint.new(latitude: 123.45, longitude: 234.56)

      assert_equal(
        [123.45, 234.56, 0, -777, 0, "", ""],
        point.to_a()
      )
    end
  end

end
