
desc "Runs the test suite"
task :test do
  args = ARGV[1..-1]

  if args.empty?
    args = Dir.glob("test/rozi/**/*.rb")
  end

  run_tests(args)
end

desc "Sets the version of the project"
task "set-version", :new_version do |t, args|
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
end

desc "Builds the gem into pkg/"
task "build" do |t|
  system("mkdir pkg") if not Dir.exist?("pkg")
  system("gem build rozi.gemspec")
  system("mv rozi-*.gem pkg")
end

task :default do
  ARGV.insert(0, "test")   # Simluate actual test command
  Rake::Task["test"].invoke
end

def run_tests(files)
  opts = []
  opts.insert(0, "--verbose") if ENV["VERBOSE"]
  opts.insert(0, "--name", ENV["TESTNAME"]) if ENV["TESTNAME"]

  exec "ruby", "-I", "lib", "test/run_tests.rb", *opts, "--", *files
end
