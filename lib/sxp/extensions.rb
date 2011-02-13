require 'rdf'

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

##
# Extensions for RDF::URI
class RDF::URI
  # Override qname to save value for SXP serialization
  def qname=(value); @qname = value; end
  def qname; @qname; end
end

