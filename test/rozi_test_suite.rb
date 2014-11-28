
require "minitest/autorun"
require "mocha/setup"

require "rozi"

module RoziTestSuite
  module Assertions

  end

  class TestCase < Minitest::Test
    include Assertions
  end

  def self.read_test_data(file_name)
    File.read(File.join(Rozi::ROOT, "test/test_data/", file_name), mode: "rb")
  end

  def self.temp_file_path(name="temp", suffix="")
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

  ##
  # Requires all Ruby files matching one of +patterns+.
  #
  # @param [Array<String>] patterns an array of glob paths
  # @return [Array<String>] a list of all required Ruby files
  #
  def self.require_patterns(patterns)
    files = []

    patterns.each { |pattern| files += Dir.glob(pattern) }

    files.each { |file|
      require_relative File.absolute_path(file)
    }

    return files
  end
end
