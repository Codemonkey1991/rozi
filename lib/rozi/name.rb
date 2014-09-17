
module Rozi

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

end
