
require "rozi/file_wrapper_base"
require "rozi/shared"

module Rozi
  ##
  # Writes an enumerable of waypoints to a file
  #
  # @param [Enumerable] waypoints
  # @param [String] file_path
  # @param [Hash] properties Any extra keyword arguments are processed as
  #   waypoint file properties
  #
  def self.write_waypoints(waypoints, file_path, **properties)
    wpt_file = WaypointFile.open(file_path, "w")

    wpt_file.write_properties(WaypointFileProperties.new(**properties))
    wpt_file.write waypoints

    wpt_file.close

    nil
  end

  ##
  # Represents a waypoint in Ozi Explorer
  #
  class Waypoint < DataStruct
    PROPERTIES = [
      :number, :name, :latitude, :longitude, :date, :symbol, :display_format,
      :fg_color, :bg_color, :description, :pointer_direction, :altitude,
      :font_size, :font_style, :symbol_size
    ]

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

    include Shared

    def initialize(*args, **kwargs)
      update(
        number: -1,
        name: "",
        latitude: 0.0,
        longitude: 0.0,
        date: nil,
        symbol: 0,
        display_format: :name_with_dot,
        fg_color: 0,
        bg_color: 65535,
        description: "",
        pointer_direction: 0,
        altitude: -777,
        font_size: 6,
        font_style: 0,
        symbol_size: 17
      )

      super
    end

    ##
    # Returns the value of the display format property
    #
    # @param [Boolean] raw If true, returns the raw value with no processing
    #
    def display_format(raw: false)
      if raw
        super
      else
        DISPLAY_FORMATS.invert[super]
      end
    end

    def display_format=(display_format)
      if display_format.is_a? Symbol
        @data[:display_format] = DISPLAY_FORMATS[display_format]
      else
        @data[:display_format] = display_format
      end
    end

    ##
    # Sets the foreground color
    #
    def fg_color=(color)
      @data[:fg_color] = interpret_color(color)
    end

    ##
    # Sets the background color
    #
    def bg_color=(color)
      @data[:bg_color] = interpret_color(color)
    end
  end

  ##
  # This class represents the waypoint file properties contained in the top 4
  # lines of a waypoint file
  #
  class WaypointFileProperties < DataStruct
    include Shared::DatumSetter

    PROPERTIES = [:datum, :version]

    def initialize(*args, **kwargs)
      update(
        datum: "WGS 84",
        version: "1.1"
      )

      super
    end
  end

  ##
  # A thin layer above +File+ that handles reading and writing of waypoints to
  # files
  #
  class WaypointFile < FileWrapperBase
    include Shared

    #@group Writing methods

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
    # Writes waypoint file properties to the file
    #
    # The file must be empty when this method is called!
    #
    # @raise [RuntimeError] if the file isn't empty
    # @param [WaypointFileProperties] properties
    # @return [nil]
    #
    def write_properties(properties)
      if @file.size > 0
        raise "Can't write file properties, file is not empty"
      end

      @file.write serialize_waypoint_file_properties(properties)
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
      ensure_file_properties

      @file.write serialize_waypoint(waypoint)
      @file.write "\n"

      nil
    end

    #@group Reading methods

    ##
    # Reads and yields all waypoints
    #
    def each_waypoint
      return to_enum(:each_waypoint) unless block_given?

      @file.rewind

      loop { yield read_waypoint }
    rescue EOFError
      return nil
    end

    ##
    # Reads the waypoint file properties
    #
    # @raise [RuntimeError] If the file position isn't 0
    # @return [WaypointFileProperties]
    #
    def read_properties
      if @file.pos != 0
        raise "File position must be 0 to read properties"
      end

      text = ""

      4.times { text << @file.readline }

      parse_waypoint_file_properties text
    end

    ##
    # Reads the next waypoint
    #
    # @raise [EOFError] When EOF is reached
    # @return [Waypoint]
    #
    def read_waypoint
      if @file.pos == 0
        read_properties
      end

      parse_waypoint @file.readline
    end

    #@endgroup

    private

    def parse_waypoint(text)
      map = {
        0  => {symbol: :number,            cast: method(:Integer)},
        1  => {symbol: :name,              cast: method(:String)},
        2  => {symbol: :latitude,          cast: method(:Float)},
        3  => {symbol: :longitude,         cast: method(:Float)},
        4  => {symbol: :date,              cast: method(:Float)},
        5  => {symbol: :symbol,            cast: method(:Integer)},
        7  => {symbol: :display_format,    cast: method(:Integer)},
        8  => {symbol: :fg_color,          cast: method(:Integer)},
        9  => {symbol: :bg_color,          cast: method(:Integer)},
        10 => {symbol: :description,       cast: method(:String)},
        11 => {symbol: :pointer_direction, cast: method(:Integer)},
        14 => {symbol: :altitude,          cast: method(:Integer)},
        15 => {symbol: :font_size,         cast: method(:Integer)},
        16 => {symbol: :font_style,        cast: method(:Integer)},
        17 => {symbol: :symbol_size,       cast: method(:Integer)},
      }

      text = text.strip
      fields = text.split(",").map { |x| x.strip }

      waypoint = Waypoint.new

      map.each_pair { |index, data|
        value = fields[index]

        next if value.empty?

        value = data[:cast].call(value)

        if value.is_a? String
          value = unescape_text(value)
        end

        waypoint.set(data[:symbol], value)
      }

      waypoint
    end

    def parse_waypoint_file_properties(text)
      lines = text.lines

      version = lines[0].strip[-3..-1]
      datum = lines[1].strip

      WaypointFileProperties.new(datum, version)
    end

    def serialize_waypoint(waypoint)
      array = waypoint.to_a
      array.map! { |item| item.is_a?(String) ? escape_text(item) : item }
      array.map! { |item| item.nil? ? "" : item }
      array.map! { |item| item.is_a?(Float) ? item.round(6) : item }

      "%d,%s,%f,%f,%s,%d,1,%d,%d,%d,%s,%d,,,%d,%d,%d,%d" % array
    end

    def serialize_waypoint_file_properties(properties)
      <<-TEXT.gsub(/^[ ]{8}/, "")
        OziExplorer Waypoint File Version #{properties.version}
        #{properties.datum}
        Reserved 2
      TEXT
    end

    ##
    # Ensures that waypoint file properties has been written to the file
    #
    def ensure_file_properties
      return if @properties_written

      @properties_written = true

      if @file.size == 0
        write_properties WaypointFileProperties.new
      end
    end
  end
end
