
require "rozi/ozi_functions"

module Rozi

  ##
  # This class writes a list of waypoints to a ".wpt" file that can be opened
  # by Ozi Explorer.
  #
  class WaypointWriter

    include OziFunctions

    def write(waypoints, file)
      file.write <<-TEXT.gsub(/^[ ]{8}/, "")
        OziExplorer Waypoint File Version 1.1
        WGS 84
        Reserved 2

      TEXT

      waypoints.each { |wpt|
        file.write(waypoint_to_text(wpt))
        file.write("\n")
      }
    end

    def waypoint_to_text(waypoint)
      wpt = waypoint.to_a()
      wpt.map! { |item| item.is_a?(String) ? escape_text(item) : item }
      wpt.map! { |item| item.nil? ? "" : item }
      wpt.map! { |item| item.is_a?(Float) ? item.round(6) : item }

      "%d,%s,%f,%f,%s,%d,1,%d,%d,%d,%s,%d,,,%d,%d,%d,%d" % wpt
    end
  end

end
