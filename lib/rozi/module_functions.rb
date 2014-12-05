
module Rozi
  module_function

  ##
  # Opens a file with the correct settings for usage with Ozi Explorer
  #
  # The file instance has UTF-8 internal encoding and ISO-8859-1 external
  # encoding. When writing, all line endings are converted to CRLF. When
  # reading, all line endings are converted to LF.
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
    opts = {undef: :replace, replace: "?"}

    if mode.include? "w"
      opts[:crlf_newline] = true
    else
      opts[:universal_newline] = true
    end

    file.set_encoding("ISO-8859-1", "UTF-8", opts)

    if block_given?
      yield file
      file.close

      return nil
    else
      return file
    end
  end
end
