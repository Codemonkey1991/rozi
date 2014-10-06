
require "rozi/ozi_functions"

module Rozi

  ##
  # This class represents a Track in Ozi Explorer. It contains attributes
  # about the track's appearance as well as a list of track points.
  #
  class Track
    attr_accessor :points

    attr_reader :color
    attr_accessor :line_width, :description, :skip_value, :type,
      :fill_type, :fill_color

    DEFAULTS = {
      line_width: 2,
      color: 255,
      description: "",
      skip_value: 1,
      type: 0,
      fill_type: 0,
      fill_color: 0
    }

    include OziFunctions

    def initialize(args={})
      @points = args[:points] || []

      DEFAULTS.each_pair { |key, value| set(key, value) }

      args.each_pair { |key, value| set(key, value) }
    end

    def color=(color)
      @color = interpret_color(color)
    end

    ##
    # @return [Array] the attributes of the track as an Array
    #
    def attributes
      [@line_width, @color, @description, @skip_value,
       @type, @fill_type, @fill_color]
    end

    ##
    # Allows adding points to the track using the `<<` syntax.
    #
    def <<(point)
      @points << point
    end

    private

    def set(key, value)
      begin
        self.send(key.to_s() + "=", value)
      rescue NoMethodError
        fail ArgumentError, "Not a valid attribute: #{key}"
      end
    end
  end

end
