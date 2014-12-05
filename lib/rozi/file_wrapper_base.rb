
module Rozi
  ##
  # Base class for classes that wrap file objects
  #
  class FileWrapperBase
    attr_accessor :file

    ##
    # Behaves like +File#open+, but returns/yields a {WaypointFile} object
    #
    def self.open(file_path, mode="r")
      file = Rozi.open_file(file_path, mode)
      wrapper = self.new(file)

      if block_given?
        begin
          return yield wrapper
        ensure
          wrapper.close unless wrapper.closed?
        end
      else
        return wrapper
      end
    end

    def initialize(file)
      @file = file
    end

    ##
    # @return [nil]
    #
    def close
      @file.close
    end

    ##
    # @return [Boolean]
    #
    def closed?
      @file.closed?
    end

    ##
    # @return [nil]
    #
    def rewind
      @file.rewind
    end
  end
end
