##
# Extensions for Ruby's `Symbol` class.
class Symbol
  ##
  # Returns `true` if this is a keyword symbol.
  #
  # @return [Boolean]
  def keyword?
    to_s[-1] == ?:
  end
end
