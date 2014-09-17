
require "stringio"

module Rozi

  class NameSearchTextWriterTest < Minitest::Test

    def setup
      @subject = NameSearchTextWriter.new
    end

    def test_write_wgs_84
      expected_output = <<-NST.gsub(/ {8}/, "")
        ;Foo
        ;Bar
        ;Baz
        #1,,
        #2,WGS 84
        Oslo,Cities,,12.34,56.78
        Bergen,Cities,,23.45,67.89
      NST

      nst = NameSearchText.new
      nst.comment = "Foo\nBar\nBaz"
      nst << Name.new("Oslo", "Cities", nil, 12.34, 56.78)
      nst << Name.new("Bergen", "Cities", nil, 23.45, 67.89)

      output = write_to_string nst

      assert_equal expected_output, output
    end

    def test_write_wgs_utm
      expected_output = <<-NST.gsub(/ {8}/, "")
        #1,UTM,32V,N
        #2,Norsk
        Oslo,Cities,,12.34,56.78
        Bergen,Cities,33,23.45,67.89
      NST

      nst = NameSearchText.new
      nst.utm = true
      nst.utm_zone = "32V"
      nst.hemisphere = "N"
      nst.datum = "Norsk"

      nst << Name.new("Oslo", "Cities", nil, 12.34, 56.78)
      nst << Name.new("Bergen", "Cities", "33", 23.45, 67.89)

      output = write_to_string nst

      assert_equal expected_output, output
    end

    def test_construct_first_line_latlng
      nst = NameSearchText.new
      nst.utm = false

      assert_equal "#1,,", @subject.send(:construct_first_line, nst)
    end

    def test_construct_first_line_utm
      nst = NameSearchText.new
      nst.utm = true
      nst.utm_zone = "32"
      nst.hemisphere = "N"

      assert_equal "#1,UTM,32,N", @subject.send(:construct_first_line, nst)

      nst.hemisphere = nil

      assert_equal "#1,UTM,32", @subject.send(:construct_first_line, nst)
    end

    def test_construct_second_line
      nst = NameSearchText.new
      nst.datum = "Egypt"

      assert_equal "#2,Egypt", @subject.send(:construct_second_line, nst)
    end

    def test_name_to_line
      name = Rozi::Name.new "Foo", "Bar", nil, 12.34, 56.78

      expected_output = "Foo,Bar,,12.34,56.78"
      output = @subject.send :name_to_line, name

      assert_equal expected_output, output
    end

    def test_name_to_line_missing_components
      name1 = Rozi::Name.new nil, "Bar", nil, 12.34, 56.78
      name2 = Rozi::Name.new "Foo", "Bar", nil, nil, nil
      name3 = Rozi::Name.new nil, "Bar", nil, nil, nil

      [name1, name2, name3].each { |name|
        assert_raises(RuntimeError) {
          @subject.send(:name_to_line, name)
        }
      }
    end

    def write_to_string(nst)
      file = StringIO.new

      @subject.write(nst, file)

      file.rewind
      return file.read
    end

  end

end
