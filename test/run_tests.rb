
require "minitest/autorun"
require "mocha/setup"

require "rozi"

ARGV.each { |file|
  load(file)
}
