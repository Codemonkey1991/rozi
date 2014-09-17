
module Rozi

  ##
  # A class for writing {Rozi::NameSearchText} objects to files.
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
        raise "name, lat and lng must be set!"
      end

      "#{name.name},#{name.feature_code},#{name.zone},#{name.lat},#{name.lng}"
    end
  end

end
