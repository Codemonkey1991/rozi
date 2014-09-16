
module Rozi

  class OziFunctionsTest < Minitest::Test
    def setup
      @subject = Class.new {
        include OziFunctions
      }.new
    end

    def test_escape_text
      assert_equal "FooÑ barÑ baz", @subject.escape_text("Foo, bar, baz")
    end

    def test_interpret_color_integer
      assert_equal 255, @subject.interpret_color(255)
    end

    def test_interpret_color_hash
      assert_equal 15715755, @subject.interpret_color("ABCDEF")
    end
  end

end
