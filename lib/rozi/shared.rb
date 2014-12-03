
module Rozi
  ##
  # Contains general functions for working with Ozi Explorer file formats
  #
  module Shared
    ##
    # Escapes commas so the text can be used in Ozi file formats
    #
    # @param [String] text
    # @return [String]
    #
    def escape_text(text)
      text.gsub(/,/, 209.chr.encode("UTF-8", "ISO-8859-1"))
    end

    ##
    # Converts the input to an RGB color represented by an integer
    #
    # @param [String, Integer] color Can be a RRGGBB hex string or an integer
    # @return [Integer]
    #
    # @example
    #   interpret_color(255)      # => 255
    #   interpret_color("ABCDEF") # => 15715755
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
    # Checks if +datum+ is a valid datum according to Ozi Explorer
    #
    # @return [Boolean] true if +datum+ is valid
    #
    def datum_valid?(datum)
      Rozi::DATUMS.include? datum
    end

    ##
    # All data structures with a datum property should include this module
    #
    module DatumSetter
      include Shared

      ##
      # Sets the datum property
      #
      # @param [String] datum
      # @raise [ArgumentError] on invalid datum
      # @return [void]
      #
      def datum=(datum)
        if not datum_valid?(datum)
          fail ArgumentError, "Invalid datum: #{datum}"
        end

        super datum
      end
    end
  end
end
