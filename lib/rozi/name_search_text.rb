
module Rozi

  ##
  # A name search text (.nst) file is a text file that can be converted into a
  # name database used by Ozi Explorer's "name search" functionality. This class
  # represents such a file and can be written to disk using
  # {Rozi::NameSearchTextWriter}.
  #
  class NameSearchText

    attr_accessor :comment, :datum, :names, :latlng,
      :utm, :utm_zone, :hemisphere

    include OziFunctions

    def initialize
      @comment = ""
      @datum = "WGS 84"
      @names = []

      @latlng = true
      @utm = false
      @utm_zone = nil
      @hemisphere = nil
    end

    def <<(name)
      @names << name
    end

    def datum=(datum)
      if not datum_valid?(datum)
        fail ArgumentError, %(Invalid datum: "#{datum}")
      end

      @datum = datum
    end
  end

end
