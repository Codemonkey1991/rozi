
require "rozi/file_wrapper_base"
require "rozi/shared"

module Rozi
  ##
  # Writes an enumerable of names to a file
  #
  # All keyword arguments are used as track properties.
  #
  # @param [Enumerable] waypoints
  # @param [String] file_path
  #
  def write_nst(enumerable, file_path, **properties)
    NameSearchTextFile.open(file_path, "w") { |nst|
      nst.write_properties NameSearchProperties.new(**properties)

      enumerable.each { |name|
        nst.write_name name
      }
    }

    return nil
  end

  ##
  # This class represents a name in an Ozi Explorer name database.
  #
  # @note The +name+, +latitude+ and +longitude+ fields must be set, or runtime errors will
  #   be raised when attempting to write to file.
  #
  class Name < DataStruct
    PROPERTIES = [:name, :feature_code, :zone, :latitude, :longitude]
  end

  ##
  # Represents the global properties of a name search text file
  #
  class NameSearchProperties < DataStruct
    PROPERTIES = [
      :comment, :datum, :latlng, :utm, :utm_zone, :hemisphere
    ]

    include Shared

    def initialize(*args, **kwargs)
      update(
        comment: "",
        datum: "WGS 84",
        latlng: true,
        utm: false,
        utm_zone: nil,
        hemisphere: nil
      )

      super
    end

    def datum=(datum)
      if not datum_valid?(datum)
        fail ArgumentError, "Invalid datum: #{datum}"
      end

      super datum
    end
  end

  ##
  # A thin layer above {File} that handles reading and writing of names to name
  # search text files
  #
  class NameSearchTextFile < FileWrapperBase
    ##
    # Writes an enumerable of {Rozi::Name} objects to the file
    #
    # @param [Enumerable] enumerable
    # @return [nil]
    #
    def write(enumerable)
      enumerable.each { |name|
        write_name name
      }

      nil
    end

    ##
    # Writes a {Rozi::Name} to the file
    #
    # @note If no properties have been written to the file before this method is
    #   called, a default set of properties will be automatically written to the
    #   file first
    # @param [Rozi::Name] name
    # @return [nil]
    #
    def write_name(name)
      ensure_properties

      @file.write serialize_name(name)
      @file.write "\n"

      nil
    end

    def write_properties(properties)
      if @file.size > 0
        raise "Can't write file properties, file is not empty"
      end

      @file.write serialize_properties(properties)
      @file.write "\n"

      nil
    end

    private

    ##
    # Ensures that properties have been written to the file
    #
    def ensure_properties
      return if @properties_written

      @properties_written = true

      if @file.size == 0
        write_properties NameSearchProperties.new
      end
    end

    def serialize_name(name)
      if not name.name or not name.latitude or not name.longitude
        fail ArgumentError, "name, latitude and longitude must be set!"
      end

      feature_code = name.feature_code || ""

      if name.name.include?(",") or feature_code.include?(",")
        fail ArgumentError, "Text cannot contain commas"
      end

      "%s,%s,%s,%s,%s" % [
        name.name, name.feature_code, name.zone,
        name.latitude.round(6), name.longitude.round(6)
      ]
    end

    def serialize_properties(properties)
      out = ""

      if properties.comment
        properties.comment.each_line { |line|
          out << ";#{line.chomp}\n"
        }
      end

      out << "#1,"

      if properties.utm
        out << "UTM,#{properties.utm_zone}"

        if properties.hemisphere
          out << ",#{properties.hemisphere}"
        end
      else
        out << ","
      end

      out << "\n#2,#{properties.datum}"

      return out
    end
  end
end
