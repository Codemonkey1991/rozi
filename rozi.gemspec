
require_relative "lib/rozi/version"

Gem::Specification.new { |s|
  s.name = "rozi"
  s.version = Rozi::VERSION
  s.date = "2014-11-07"
  s.summary = "A gem for working with several Ozi Explorer file formats"
  s.description = "A gem for working with several Ozi Explorer file formats"
  s.homepage = "https://github.com/Hubro/rozi"
  s.authors = ["Tomas Sandven"]
  s.email = "tomas191191@gmail.com"
  s.files = Dir["lib/**/*.rb", "test_data/*"] + ["README.rdoc", "LICENSE.txt"]
  s.test_files = Dir["test/**/*_test.rb"]
  s.license = "GPL"
}
