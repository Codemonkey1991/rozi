
module Rozi

  class TrackPoint
    attr_accessor :latitude, :longitude, :break, :altitude, :date,
      :date_string, :time_string

    DEFAULTS = {
      break: 0,
      altitude: -777,
      date: 0,
      date_string: "",
      time_string: ""
    }

    def initialize(args={})
      DEFAULTS.each_pair { |key, value| set(key, value) }

      args.each_pair { |key, value| set(key, value) }
    end

    def to_a
      [@latitude, @longitude, @break, @altitude,
       @date, @date_string, @time_string]
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
