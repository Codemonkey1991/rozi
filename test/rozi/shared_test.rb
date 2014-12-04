
module RoziTestSuite
  class SharedTest < Minitest::Test
    def setup
      @subject = Class.new {
        include Rozi::Shared
      }.new
    end

    def test_escape_text
      assert_equal "FooÑ barÑ baz", @subject.escape_text("Foo, bar, baz")
    end

    def test_unescape_text
      assert_equal "Foo, bar, baz", @subject.unescape_text("FooÑ barÑ baz")
    end

    def test_interpret_color_integer
      assert_equal 255, @subject.interpret_color(255)
    end

    def test_interpret_color_hash
      assert_equal 15715755, @subject.interpret_color("ABCDEF")
    end

    def test_datum_valid?
      assert @subject.datum_valid?("WGS 84")
      assert @subject.datum_valid?("Norsk")
      assert @subject.datum_valid?("Egypt")

      refute @subject.datum_valid?("Coolywobbles")
      refute @subject.datum_valid?("Rambunctious")
    end

    class DatumSetterTest < Minitest::Test
      def setup
        @subject = DataStruct(:datum) {
          include Rozi::Shared::DatumSetter
        }.new
      end

      def test_setting_invalid_datum
        assert_raises(ArgumentError) {
          @subject.datum = "Foo"
        }
      end

      def test_setting_datum
        @subject.datum = "Norsk"
      end
    end
  end
end
