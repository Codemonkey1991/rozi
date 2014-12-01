
module Rozi
  class TrackTest < Minitest::Test
    def test_initialize_defaults
      t = Track.new()

      Track::DEFAULTS.each_pair { |key, value|
        assert_equal value, t.send(key)
      }
    end

    def test_initialize_with_args
      points = [:foo, :bar]
      attrs = {points: points, line_width: 2, type: 10}

      t = Track.new(attrs)

      attrs.each_pair { |key, value|
        assert_equal value, t.send(key)
      }
    end
  end
end
