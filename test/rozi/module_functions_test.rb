
require "tempfile"

module Rozi
  class ModuleFunctionsTest < Minitest::Test

    def test_open_file
      temp_file_path { |file_path|
        file = Rozi.open_file(file_path, "w")
        file.write("foo\nbar\næøå")
        file.close

        text = File.read(file_path, mode: "rb").force_encoding("ISO-8859-1")

        assert_equal "foo\r\nbar\r\næøå".encode("ISO-8859-1"), text
      }
    end

    def test_open_file_with_block
      temp_file_path { |file_path|
        f = nil

        Rozi.open_file(file_path, "w") { |file|
          assert_instance_of File, file

          f = file
        }

        assert f.closed?
      }
    end

    # def test_write_track
    #   track = Rozi::Track.new()
    #   track << Rozi::TrackPoint.new(latitude: 59.91273, longitude: 10.74609)
    #   track << Rozi::TrackPoint.new(latitude: 60.39358, longitude: 5.32476)
    #   track << Rozi::TrackPoint.new(latitude: 62.56749, longitude: 7.68709)

    #   temp_file_path { |file_path|
    #     Rozi.write_track(track, file_path)

    #     text = File.read(file_path, mode: "rb")
    #     expected_output = read_test_file("expected_output_1.plt")

    #     assert_equal expected_output, text
    #   }
    # end

    private

    def read_test_file(name)
      path = File.join(Rozi::ROOT, "test/test_data", name)

      File.read(path, mode: "rb")
    end

    def temp_file_path(name="temp", suffix="")
      path = Dir::Tmpname.make_tmpname(
        "#{Dir::Tmpname.tmpdir}/rozi", "#{name}#{suffix}"
      )

      if block_given?
        begin
          yield path
        ensure
          File.unlink path if File.exist? path
        end
      else
        return path
      end
    end

  end
end
