
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

    def test_symbol
      wp = Waypoint.new()
      wp.symbol = :house

      assert_equal :house, wp.symbol
      assert_equal 10, wp.symbol(:number)
    end

    def test_colors
      wp = Waypoint.new()

      wp.fg_color = "000000"
      assert_equal 0, wp.fg_color

      wp.fg_color = "ABCDEF"
      assert_equal 15715755, wp.fg_color

      wp.fg_color = 128
      assert_equal 128, wp.fg_color
    end
  end

end
