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

# Update RDF::URI if RDF is loaded
begin
  require 'rdf'

  ##
  # Extensions for RDF::URI
  class RDF::URI
    # Original lexical value of this URI to allow for round-trip serialization.
    def lexical=(value); @lexical = value; end
    def lexical; @lexical; end
  end
rescue LoadError
  # Ignore
end
