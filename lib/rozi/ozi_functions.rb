
module Rozi

  ##
  # Contains general functions for working with Ozi Explorer file formats.
  #
  module OziFunctions
    ##
    # Escapes commas so the text can be used in Ozi file formats.
    #
    # @param [String] text
    # @return [String]
    #
    def escape_text(text)
      text.gsub(/,/, 209.chr.encode("UTF-8", "ISO-8859-1"))
    end

    ##
    # Converts the input to an RGB color represented by an integer.
    #
    # @param [String, Integer] color Can be a RRGGBB hex string or an integer.
    # @return [Integer]
    #
    # @example
    #   interpret_color(255)      # 255
    #   interpret_color("ABCDEF") # 15715755
    #
    def interpret_color(color)
      if color.is_a? String
        # Turns RRGGBB into BBGGRR for hex conversion.
        color = color[-2..-1] << color[2..3] << color[0..1]
        color = color.to_i(16)
      end

      color
    end

    ##
    # Opens a file handle with the correct settings for writing an Ozi
    # Explorer file format.
    #
    # @param [String] path
    # @return [File]
    #
    def open_file_for_writing(path)
      if block_given?
        file = File.open(path, "w") { |f|
          f.set_encoding("ISO-8859-1", "UTF-8", crlf_newline: true)
          yield f
        }

        return nil
      else
        file = File.open(path, "w")
        file.set_encoding("ISO-8859-1", "UTF-8", crlf_newline: true)

        return file
      end
    end
  end

end
