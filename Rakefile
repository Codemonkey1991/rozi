
desc("Runs the test suite")
task("test") { |t|
  system('ruby -I lib -r minitest/autorun -r mocha/setup -e "ARGV.each { |file| load(file) }" test/**/*_test.rb')
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

desc("Hosts an auto-reloading doc server")
task("doc-server") { |t|
  system("yard server -r README")
}
