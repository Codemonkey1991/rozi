
require "rozi/file_wrapper_base"
require "rozi/shared"

module Rozi
  ##
  # Writes an enumerable of track points to a file
  #
  # All keyword arguments are used as track properties.
  #
  # @param [Enumerable] enumerable
  # @param [String] file_path
  #
  def write_track(enumerable, file_path, **properties)
    TrackFile.open(file_path, "w") { |track_file|
      track_file.write_track_properties TrackProperties.new(**properties)
      track_file.write enumerable
    }
  end

  ##
  # Represents a point in an Ozi Explorer track
  #
  class TrackPoint < DataStruct
    PROPERTIES = [
      :latitude, :longitude, :break, :altitude,
      :date, :date_string, :time_string
    ]

    def initialize(*args, **kwargs)
      update(
        break: false,
        altitude: -777,
        date: 0,
        date_string: "",
        time_string: ""
      )

      super
    end

    def break
      super == 1
    end

    def break=(brk)
      super(brk ? 1 : 0)
    end
  end

  ##
  # Represents the track properties at the top of an Ozi Explorer track file
  #
  class TrackProperties < DataStruct
    PROPERTIES = [
      :datum, :line_width, :color, :description, :skip_value,
      :type, :fill_style, :fill_color
    ]

    include Shared
    include Shared::DatumSetter

    def initialize(*args, **kwargs)
      update(
        datum: "WGS 84",
        line_width: 2,
        color: 255,
        description: "",
        skip_value: 1,
        type: 0,
        fill_style: 0,
        fill_color: 0
      )

      super
    end

    def color=(color)
      super interpret_color(color)
    end
  end

  ##
  # A thin wrapper around a file object made for reading and writing tracks
  #
  class TrackFile < FileWrapperBase
    include Shared

    ##
    # Writes track properties to the file
    #
    # @warn The file *must be empty* when this method is called
    #
    # @param [TrackProperties] track_properties
    # @return [nil]
    #
    def write_track_properties(track_properties)
      if @file.size > 0
        raise "Can't write file properties, file is not empty"
      end

      @file.write serialize_track_properties(track_properties)

      nil
    end

    ##
    # Writes a track point to the file
    #
    # @param [TrackPoint] track_point
    # @return [nil]
    #
    def write_track_point(track_point)
      ensure_track_properties

      @file.write serialize_track_point(track_point)
      @file.write "\n"

      nil
    end

    ##
    # Writes an enumerable of track points to the file
    #
    # @param [Enumerable] enumerable
    #
    def write(enumerable)
      enumerable.each { |track_point|
        self.write_track_point(track_point)
      }

      nil
    end

    private

    ##
    # Ensures that track properties has been written to the file
    #
    def ensure_track_properties
      return if @properties_written

      @properties_written = true

      if @file.size == 0
        write_track_properties TrackProperties.new
      end
    end

    def serialize_track_properties(track_properties)
      props = track_properties.to_a
      props.delete_at(0)   # The datum isn't a part of this list
      props.map! { |item| item.is_a?(String) ? escape_text(item) : item }

      <<-TEXT.gsub(/^[ ]{8}/, "") % props
        OziExplorer Track Point File Version 2.1
        #{track_properties.datum}
        Altitude is in Feet
        Reserved 3
        0,%d,%d,%s,%d,%d,%d,%d
        0
      TEXT
    end

    def serialize_track_point(track_point)
      "  %.6f,%.6f,%d,%.1f,%.7f,%s,%s" % track_point.to_a
    end
  end
end
