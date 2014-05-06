
module Rozi
  def self.load_lib
    this_dir = File.absolute_path(File.dirname(__FILE__))
    source_files = Dir[File.join(this_dir, "rozi/**/*.rb")]

    source_files.each { |file|
      load(file)
    }
  end
end

Rozi.load_lib()
