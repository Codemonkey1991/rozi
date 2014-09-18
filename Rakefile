
desc("Runs the test suite")
task("test") { |t|
  test_files = ARGV[1..ARGV.count]

  if test_files.empty?
    test_files = Dir["test/rozi/**/*.rb"]
  end

  puts "Running #{test_files.count} test case(s):"
  puts
  test_files.each { |path| puts path }
  puts

  # Quotes are added around the paths in case of spaces.
  test_files = test_files.map { |path| %("#{path}") }.join(" ")

  exec("ruby -I lib test/run_tests.rb #{test_files}")
}

desc("Sets the version of the project")
task("set-version", :new_version) { |t, args|
  require_relative "lib/rozi/version"

  if args.count != 1
    puts "Usage: rake set-version[x.x.x]"
    exit(1)
  end

  new_date = Time.now.to_s[0..9]

  ["lib/rozi/version.rb", "rozi.gemspec"].each { |file|
    text = File.read file

    text.gsub! Rozi::VERSION, args[:new_version]
    text.gsub! /^  s\.date = .*$/, %(  s.date = "#{new_date}")

    File.open(file, "w") { |file|
      file.write text
    }
  }

  puts "Version set to #{args[:new_version]}"
  puts "Date updated to #{new_date}"
}

desc("Builds the gem into pkg/")
task("build") { |t|
  system("mkdir pkg") if not Dir.exist?("pkg")
  system("gem build rozi.gemspec")
  system("mv rozi-*.gem pkg")
}
