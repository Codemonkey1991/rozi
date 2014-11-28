
require "rozi/ozi_functions"

module Rozi

  def write_waypoints(waypoints, file, **meta)
    file.write WaypointMetadata.new(**meta)

    waypoints.each { |wpt|
      file.write wpt
      file.write "\n"
    }
  end

  ##
  # Represents a waypoint in Ozi Explorer.
  #
  class Waypoint

    include OziFunctions

    DISPLAY_FORMATS = {
      :number_only => 0,
      :name_only => 1,
      :number_and_name => 2,
      :name_with_dot => 3,
      :name_with_symbol => 4,
      :symbol_only => 5,
      :comment_with_symbol => 6,
      :man_overboard => 7,
      :marker => 8
    }

    attr_accessor :number, :name, :latitude, :longitude, :date, :symbol,
      :display_format, :description, :pointer_direction, :altitude,
      :font_size, :font_style, :symbol_size

    attr_reader :fg_color, :bg_color

    def self.from_text(text)
      fail "Not implemented"
    end

    def initialize(args={})
      @number = -1
      @name = ""
      @latitude = 0.0
      @longitude = 0.0
      @date = nil
      @symbol = 0
      @display_format = :name_with_dot
      @fg_color = 0
      @bg_color = 65535
      @description = ""
      @pointer_direction = 0
      @altitude = -777
      @font_size = 6
      @font_style = 0
      @symbol_size = 17

      args.each_pair { |key, value|
        begin
          self.send(key.to_s() + "=", value)
        rescue NoMethodError
          fail ArgumentError, "Not a valid attribute: #{key}"
        end
      }
    end

    def to_a
      [@number,
       @name,
       @latitude,
       @longitude,
       @date,
       @symbol,
       DISPLAY_FORMATS[@display_format],
       @fg_color,
       @bg_color,
       @description,
       @pointer_direction,
       @altitude,
       @font_size,
       @font_style,
       @symbol_size]
    end

    def to_s
      array = self.to_a()
      array.map! { |item| item.is_a?(String) ? escape_text(item) : item }
      array.map! { |item| item.nil? ? "" : item }
      array.map! { |item| item.is_a?(Float) ? item.round(6) : item }

      "%d,%s,%f,%f,%s,%d,1,%d,%d,%d,%s,%d,,,%d,%d,%d,%d" % array
    end

    ##
    # Sets the foreground color. Accepts a hex string or a decimal value.
    #
    def fg_color=(color)
      @fg_color = interpret_color(color)
    end

    ##
    # Sets the background color. Accepts a hex string or a decimal value.
    #
    def bg_color=(color)
      @bg_color = interpret_color(color)
    end
  end

  ##
  # This class represents the meta data contained in the top 4 lines of a
  # waypoint file
  #
  class WaypointMetadata
    ##
    # @return [String]
    # @see Rozi::DATUMS
    #
    attr_accessor :datum

    ##
    # @return [String]
    #
    attr_accessor :version

    def self.from_text(text)
      fail "Not implemented"
    end

    def initialize(datum: "WGS 84", version: "1.1")
      @datum = datum
      @version = version
    end

    def to_s
      <<-TEXT.gsub(/^[ ]{8}/, "")
        OziExplorer Waypoint File Version #{@version}
        #{@datum}
        Reserved 2
      TEXT
    end
  end

  ##
  # A thin layer above {File} that handles reading and writing of waypoints to
  # files
  #
  class WaypointFile
    ##
    # Behaves like {File#open}, but returns/yields a {WaypointFile} object
    #
    def self.open(file_path, mode="r")
      file = Rozi.open_file(file_path, mode)
      wptfile = WaypointFile.new(file)

      if block_given?
        begin
          return yield wptfile
        ensure
          wptfile.close unless wptfile.closed?
        end
      else
        return wptfile
      end
    end

    def initialize(file)
      @file = file
      @metadata_written = false
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
    # Writes waypoints to the file
    #
    # @param [Enumerator<Waypoint>] waypoints
    # @return [nil]
    #
    def write(waypoints)
      waypoints.each { |wpt|
        write_waypoint wpt
      }

      nil
    end

    ##
    # Writes metadata to the file
    #
    # This function can only be used on an *empty* file. If any waypoints are
    # written to the file before metadata is written, a {WaypointMetadata}
    # object will be created with default values and written to the file first.
    # Executing this function on a non-empty file will result in a runtime
    # error.
    #
    # @param [WaypointMetadata] metadata
    # @return [nil]
    #
    def write_metadata(metadata)
      if @file.size > 0
        raise "Can't write metadata, file is not empty"
      end

      @file.write metadata.to_s
      @file.write "\n"

      nil
    end

    ##
    # Writes a waypoint to the file
    #
    # @param [Waypoint] waypoint
    # @return [nil]
    #
    def write_waypoint(waypoint)
      @file.write waypoint.to_s
      @file.write "\n"

      nil
    end

    private

    ##
    # Ensures that waypoint metadata has been written to the file
    #
    def ensure_metadata
      return if @metadata_written

      @metadata_written = true

      if @file.size == 0
        write_metadata WaypointMetadata.new
      end
    end
  end
end
