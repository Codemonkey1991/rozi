
require "rozi/ozi_functions"

module Rozi

  class TrackWriter

    include OziFunctions

    ##
    # Writes the track to +file+ as an Ozi Explorer track file. The file
    # extension should be ".plt".
    #
    # @param [AddressKit::Ozi::Track] track
    # @param [File, String, #write] file
    #
    def write(track, file)
      file.write <<-TEXT.gsub(/^[ ]{8}/, "")
        OziExplorer Track Point File Version 2.1
        WGS 84
        Altitude is in Feet
        Reserved 3
      TEXT

      file.write(track_attributes_to_text(track))
      file.write("\n")

      file.write(track.points.count.to_s() + "\n")

      track.points.each { |point|
        file.write(track_point_to_text(point))
        file.write("\n")
      }
    end

    def track_attributes_to_text(track)
      attrs = track.attributes
      attrs.map! { |item| item.is_a?(String) ? escape_text(item) : item }

      "0,%d,%d,%s,%d,%d,%d,%d" % attrs
    end

    def track_point_to_text(point)
      p = point.to_a()

      "  %.6f,%.6f,%d,%.1f,%.7f,%s,%s" % p
    end
  end

end
