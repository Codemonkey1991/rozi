
require "minitest/autorun"
require "mocha/setup"

require "rozi"

module RoziTestSuite
  module Assertions

  end

  class TestCase < Minitest::Test
    include Assertions
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
