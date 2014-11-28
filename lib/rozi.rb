
module Rozi
  extend self

  ROOT = File.expand_path("../", File.dirname(__FILE__))

  ##
  # Loads all ruby files under lib/rozi. Called automatically when requiring
  # "rozi.rb".
  #
  def require_lib
    this_dir = File.absolute_path(File.dirname(__FILE__))
    source_files = Dir[File.join(this_dir, "rozi/**/*.rb")]

    source_files.each { |file|
      require_relative file
    }
  end
end

Rozi.require_lib
