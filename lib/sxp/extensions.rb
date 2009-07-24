class Symbol
  ##
  # Returns +true+ if this is a keyword symbol.
  def keyword?
    to_s[-1] == ?:
  end
end
