
desc("Runs the test suite")
task("test") { |t|
  test_files = ARGV[1..ARGV.count]

  if test_files.empty?
    test_files = Dir["test/rozi/**/*.rb"]
  end

  puts "Running #{test_files.count} test case(s)"
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

  ["lib/rozi/version.rb", "rozi.gemspec"].each { |file|
    new = `sed "s/#{Rozi::VERSION}/#{args[:new_version]}/" #{file}`

    File.open(file, "w") { |file|
      file.write(new)
    }
  }

  puts "Version set to #{args[:new_version]}"
}

desc("Builds the gem into pkg/")
task("build") { |t|
  system("mkdir pkg") if not Dir.exist?("pkg")
  system("gem build rozi.gemspec")
  system("mv rozi-*.gem pkg")
}
