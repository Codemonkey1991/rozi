
require "rozi/file_wrapper_base"
require "rozi/shared"

module Rozi
  ##
  # Writes a {Rozi::NameSearchText} object to a file.
  #
  # @see Rozi::NameSearchTextWriter#write
  #
  def write_nst(nst, file)
    @@nst_writer ||= NameSearchTextWriter.new

    if file.is_a? String
      open_file(file, "w") { |f|
        @@nst_writer.write(nst, f)
      }
    else
      @@nst_writer.write(nst, file)
    end

    return nil
  end

  ##
  # This class represents a name in an Ozi Explorer name database.
  #
  # @note The +name+, +lat+ and +lng+ fields must be set, or runtime errors will
  #   be raised when attempting to write to file.
  #
  class Name

    attr_accessor :name, :feature_code, :zone, :lat, :lng

    def initialize(name=nil, feature_code=nil, zone=nil, lat=nil, lng=nil)
      @name = name
      @feature_code = feature_code
      @zone = zone
      @lat = lat
      @lng = lng
    end
  end

  ##
  # A name search text (.nst) file is a text file that can be converted into a
  # name database used by Ozi Explorer's "name search" functionality. This class
  # represents such a file and can be written to disk using
  # {Rozi::NameSearchTextWriter}.
  #
  class NameSearchText

    attr_accessor :comment, :datum, :names, :latlng,
      :utm, :utm_zone, :hemisphere

    include Shared

    def initialize
      @comment = ""
      @datum = "WGS 84"
      @names = []

      @latlng = true
      @utm = false
      @utm_zone = nil
      @hemisphere = nil
    end

    def <<(name)
      @names << name
    end

    def datum=(datum)
      if not datum_valid?(datum)
        fail ArgumentError, %(Invalid datum: "#{datum}")
      end

      @datum = datum
    end
  end

  ##
  # A class for writing {Rozi::NameSearchText} objects to files.
  #
  # @note Text in name search files (names and feature codes) cannot contain
  #   commas. There is no mechanism for escaping commas or substituting them
  #   with different symbols like in waypoint files.
  #
  class NameSearchTextWriter

    ##
    # Writes +nst+ to +file+.
    #
    # @param [Rozi::NameSearchText] nst
    # @param [File, StringIO] file an open file object
    #
    def write(nst, file)
      if nst.comment
        nst.comment.each_line { |line|
          file.write ";#{line.chomp}\n"
        }
      end

      file.write construct_first_line(nst) << "\n"
      file.write construct_second_line(nst) << "\n"

      nst.names.each { |name|
        file.write name_to_line(name) << "\n"
      }

      return nil
    end

    private

    def construct_first_line(nst)
      first_line = "#1,"

      if nst.utm
        first_line << "UTM,#{nst.utm_zone}"

        if nst.hemisphere
          first_line << ",#{nst.hemisphere}"
        end
      else
        first_line << ","
      end

      return first_line
    end

    def construct_second_line(nst)
      "#2,#{nst.datum}"
    end

    def name_to_line(name)
      if not name.name or not name.lat or not name.lng
        fail "name, lat and lng must be set!"
      end

      if name.name.include?(",") or name.feature_code.include?(",")
        fail ArgumentError, "Text cannot contain commas"
      end

      "#{name.name},#{name.feature_code},#{name.zone},#{name.lat},#{name.lng}"
    end
  end
end
