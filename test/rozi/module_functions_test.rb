
require "tempfile"

module RoziTestSuite
  class ModuleFunctionsTest < Minitest::Test
    def test_open_file
      RoziTestSuite.temp_file_path { |file_path|
        file = Rozi.open_file(file_path, "w")
        file.write("foo\nbar\næøå")
        file.close

        text = File.read(file_path, mode: "rb").force_encoding("ISO-8859-1")

        assert_equal "foo\r\nbar\r\næøå".encode("ISO-8859-1"), text

        file = Rozi.open_file(file_path, "r")
        assert_equal "foo\nbar\næøå", file.read
        file.close
      }
    end

    def test_open_file_with_block
      RoziTestSuite.temp_file_path { |file_path|
        f = nil

        Rozi.open_file(file_path, "w") { |file|
          assert_instance_of File, file

          f = file
        }

        assert f.closed?
      }
    end
  end
end
