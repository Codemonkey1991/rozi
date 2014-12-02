
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
end
