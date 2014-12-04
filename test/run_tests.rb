
require_relative "rozi_test_suite.rb"

if ARGV.index("--").nil?
  test_files = []
else
  files_index = ARGV.index("--") + 1
  test_files = ARGV[files_index..-1]

  # Everything after and including the -- is removed from ARGV, as to not
  # confuse Minitest.
  ARGV.slice!(files_index - 1, ARGV.length)
end

files = RoziTestSuite.require_patterns test_files

puts "Included files:"
puts

files.each { |file|
  puts file
}

puts
