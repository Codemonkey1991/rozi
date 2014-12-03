
module RoziTestSuite
  class WriteNstTest < Minitest::Test
    def setup
      @subject = Rozi.method(:write_nst)
    end

    def test_basic_usage
      expected_output = RoziTestSuite.read_test_data("expected_output_1.nst")

      names = [
        Rozi::Name.new(
          name: "Oslo", latitude: 59.913309, longitude: 10.753188
        ),
        Rozi::Name.new(
          name: "Bergen", latitude: 60.389966, longitude: 5.323434
        ),
        Rozi::Name.new(
          name: "Trondheim", latitude: 63.429949, longitude: 10.395332
        )
      ]

      file = StringIO.new
      Rozi.expects(:open_file).returns(file)

      Rozi.write_nst(names, nil, comment: "Rozi test suite")

      assert_equal expected_output, file.string
    end
  end

  class NameSearchPropertiesTest < Minitest::Test
    def setup
      @subject = Rozi::NameSearchProperties.new
    end

    def test_setting_datum
      @subject.datum = "Norsk"
      assert_equal "Norsk", @subject.datum
    end

    def test_setting_invalid_datum
      assert_raises(ArgumentError) {
        @subject.datum = "Foo"
      }
    end
  end

  class NameSearchTextFileTest < Minitest::Test
    def setup
      @subject = Rozi::NameSearchTextFile.new(mock())
    end

    def test_write_name_empty_file
      @subject.file = StringIO.new

      # Each write performs two file writes, one for the object and one for the
      # line break. We expect the properties to be written once, and each of the
      # names to be written - 3*2=6
      @subject.file.expects(:write).times(6)

      @subject.write_name Rozi::Name.new(
        name: "Oslo", latitude: 59.913309, longitude: 10.753188
      )
      @subject.write_name Rozi::Name.new(
        name: "Bergen", latitude: 60.389966, longitude: 5.323434
      )
    end

    def test_write_properties_non_empty_file
      @subject.file.expects(:size).returns(1)

      assert_raises(RuntimeError) {
        @subject.write_properties(Rozi::NameSearchProperties.new)
      }
    end

    def test_serialize_name_utm32
      name = Rozi::Name.new("Oslo S", "Places", "32V", 6642760, 597993)

      assert_equal(
        "Oslo S,Places,32V,6642760.0,597993.0",
        @subject.send(:serialize_name, name)
      )
    end

    def test_serialize_name_decimal_wgs84
      expected_output = "Oslo S,Places,,59.910683,10.752267"
      name = Rozi::Name.new("Oslo S", "Places", nil, 59.910683132, 10.752267219)

      assert_equal expected_output, @subject.send(:serialize_name, name)
    end

    def test_serialize_properties_utm32
      expected_output = "#1,UTM,32V,N\n#2,Norsk"

      props = Rozi::NameSearchProperties.new(
        utm: true, utm_zone: "32V", hemisphere: "N", datum: "Norsk"
      )

      assert_equal expected_output, @subject.send(:serialize_properties, props)
    end

    def test_serialize_properties_wgs84
      expected_output = "#1,,\n#2,WGS 84"

      props = Rozi::NameSearchProperties.new

      assert_equal expected_output, @subject.send(:serialize_properties, props)
    end

    def test_serialize_properties_with_comments
      expected_output = ";foo bar\n;test test\n#1,,\n#2,WGS 84"

      props = Rozi::NameSearchProperties.new(comment: "foo bar\ntest test")

      assert_equal expected_output, @subject.send(:serialize_properties, props)
    end
  end

  # class NameSearchTextTest < Minitest::Test
  #   def setup
  #     @subject = NameSearchText.new
  #   end

  #   def test_add_name
  #     @subject << :foo
  #     @subject << :bar

  #     assert_equal [:foo, :bar], @subject.names
  #   end

  #   def test_set_datum
  #     @subject.datum = "WGS 84"
  #     @subject.datum = "Adindan"

  #     assert_raises(ArgumentError) {
  #       @subject.datum = "Foo bar"
  #     }
  #   end
  # end

  # class NameSearchTextWriterTest < Minitest::Test
  #   def setup
  #     @subject = NameSearchTextWriter.new
  #   end

  #   def test_write_wgs_84
  #     expected_output = <<-NST.gsub(/ {8}/, "")
  #       ;Foo
  #       ;Bar
  #       ;Baz
  #       #1,,
  #       #2,WGS 84
  #       Oslo,Cities,,12.340000,56.780000
  #       Bergen,Cities,,23.450000,67.890000
  #     NST

  #     nst = NameSearchText.new
  #     nst.comment = "Foo\nBar\nBaz"
  #     nst << Name.new("Oslo", "Cities", nil, 12.34, 56.78)
  #     nst << Name.new("Bergen", "Cities", nil, 23.45, 67.89)

  #     output = write_to_string nst

  #     assert_equal expected_output, output
  #   end

  #   def test_write_wgs_utm
  #     expected_output = <<-NST.gsub(/ {8}/, "")
  #       #1,UTM,32V,N
  #       #2,Norsk
  #       Oslo,Cities,,12.340000,56.780000
  #       Bergen,Cities,33,23.450000,67.890000
  #     NST

  #     nst = NameSearchText.new
  #     nst.utm = true
  #     nst.utm_zone = "32V"
  #     nst.hemisphere = "N"
  #     nst.datum = "Norsk"

  #     nst << Name.new("Oslo", "Cities", nil, 12.34, 56.78)
  #     nst << Name.new("Bergen", "Cities", "33", 23.45, 67.89)

  #     output = write_to_string nst

  #     assert_equal expected_output, output
  #   end

  #   def test_construct_first_line_latlng
  #     nst = NameSearchText.new
  #     nst.utm = false

  #     assert_equal "#1,,", @subject.send(:construct_first_line, nst)
  #   end

  #   def test_construct_first_line_utm
  #     nst = NameSearchText.new
  #     nst.utm = true
  #     nst.utm_zone = "32"
  #     nst.hemisphere = "N"

  #     assert_equal "#1,UTM,32,N", @subject.send(:construct_first_line, nst)

  #     nst.hemisphere = nil

  #     assert_equal "#1,UTM,32", @subject.send(:construct_first_line, nst)
  #   end

  #   def test_construct_second_line
  #     nst = NameSearchText.new
  #     nst.datum = "Egypt"

  #     assert_equal "#2,Egypt", @subject.send(:construct_second_line, nst)
  #   end

  #   def test_name_to_line
  #     name = Rozi::Name.new "Foo", "Bar", nil, 12.34, 56.78

  #     expected_output = "Foo,Bar,,12.340000,56.780000"
  #     output = @subject.send :name_to_line, name

  #     assert_equal expected_output, output
  #   end

  #   def test_name_to_line_missing_components
  #     name1 = Rozi::Name.new nil, "Bar", nil, 12.34, 56.78
  #     name2 = Rozi::Name.new "Foo", "Bar", nil, nil, nil
  #     name3 = Rozi::Name.new nil, "Bar", nil, nil, nil

  #     [name1, name2, name3].each { |name|
  #       assert_raises(RuntimeError) {
  #         @subject.send(:name_to_line, name)
  #       }
  #     }
  #   end

  #   def write_to_string(nst)
  #     file = StringIO.new

  #     @subject.write(nst, file)

  #     file.rewind
  #     return file.read
  #   end
  # end
end
