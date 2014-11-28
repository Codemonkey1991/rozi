
module Rozi

  module_function

  ##
  # Opens a file with the correct settings for usage with Ozi Explorer
  #
  # @overload open_file(path, mode="r")
  #
  #   @param [String] path
  #   @return [File]
  #
  # @overload open_file(path, mode="r")
  #
  #   Can be called with a block, just like file +File.open+.
  #
  #   @yieldparam [File] file
  #   @return [void]
  #
  def open_file(path, mode="r")
    file = File.open(path, mode)
    file.set_encoding(
      "ISO-8859-1", "UTF-8",
      crlf_newline: true, undef: :replace, replace: "?"
    )

    if block_given?
      yield file
      file.close

      return nil
    else
      return file
    end
  end

  # ##
  # # Writes an array of waypoints to a file.
  # #
  # # @see Rozi::WaypointWriter#write
  # #
  # def write_waypoints(waypoints, file)
  #   @@wpt_writer ||= WaypointWriter.new

  #   if file.is_a? String
  #     open_file(file, "w") { |f|
  #       @@wpt_writer.write(waypoints, f)
  #     }
  #   else
  #     @@wpt_writer.write(waypoints, file)
  #   end

  #   return nil
  # end

  ##
  # Writes a track to a file.
  #
  # @see Rozi::TrackWriter#write
  #
  def write_track(track, file)
    @@track_writer ||= TrackWriter.new

    if file.is_a? String
      open_file(file, "w") { |f|
        @@track_writer.write(track, f)
      }
    else
      @@track_writer.write(track, file)
    end

    return nil
  end

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
end
