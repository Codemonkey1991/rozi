
require "rozi/ozi_functions"

module Rozi

  ##
  # Represents a waypoint in Ozi Explorer.
  #
  class Waypoint

    include OziFunctions

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

    attr_accessor :number, :name, :latitude, :longitude, :date, :symbol,
      :display_format, :description, :pointer_direction, :altitude,
      :font_size, :font_style, :symbol_size

    attr_reader :fg_color, :bg_color

    def initialize(args={})
      @number = -1
      @name = ""
      @latitude = 0.0
      @longitude = 0.0
      @date = nil
      @symbol = 0
      @display_format = :name_with_dot
      @fg_color = 0
      @bg_color = 65535
      @description = ""
      @pointer_direction = 0
      @altitude = -777
      @font_size = 6
      @font_style = 0
      @symbol_size = 17

      args.each_pair { |key, value|
        begin
          self.send(key.to_s() + "=", value)
        rescue NoMethodError
          fail ArgumentError, "Not a valid attribute: #{key}"
        end
      }
    end

    def to_a
      [@number,
       @name,
       @latitude,
       @longitude,
       @date,
       @symbol,
       DISPLAY_FORMATS[@display_format],
       @fg_color,
       @bg_color,
       @description,
       @pointer_direction,
       @altitude,
       @font_size,
       @font_style,
       @symbol_size]
    end

    ##
    # Sets the foreground color. Accepts a hex string or a decimal value.
    #
    def fg_color=(color)
      @fg_color = interpret_color(color)
    end

    ##
    # Sets the background color. Accepts a hex string or a decimal value.
    #
    def bg_color=(color)
      @bg_color = interpret_color(color)
    end
  end

end
