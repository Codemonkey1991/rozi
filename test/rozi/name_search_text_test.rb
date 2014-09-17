
module Rozi

  class NameSearchTextTest < Minitest::Test

    def setup
      @subject = NameSearchText.new
    end

    def test_add_name
      @subject << :foo
      @subject << :bar

      assert_equal [:foo, :bar], @subject.names
    end

    def test_set_datum
      @subject.datum = "WGS 84"
      @subject.datum = "Adindan"

      assert_raises(ArgumentError) {
        @subject.datum = "Foo bar"
      }
    end

  end

end
