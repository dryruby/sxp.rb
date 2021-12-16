# -*- encoding: utf-8 -*-
require 'bigdecimal'
require 'time'

##
# Extensions for Ruby's `Object` class.
class Object
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    to_s.to_json
  end
end

##
# Extensions for Ruby's `NilClass` class.
class NilClass
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '#n'
  end
end

##
# Extensions for Ruby's `FalseClass` class.
class FalseClass
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '#f'
  end
end

##
# Extensions for Ruby's `TrueClass` class.
class TrueClass
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '#t'
  end
end

##
# Extensions for Ruby's `String` class.
class String
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    inspect
  end
end

##
# Extensions for Ruby's `Symbol` class.
class Symbol
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    to_s
  end

  ##
  # Returns `true` if this is a keyword symbol.
  #
  # @return [Boolean]
  def keyword?
    to_s[-1] == ?:
  end
end

##
# Extensions for Ruby's `Integer` class.
class Integer
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    to_s
  end
end

##
# Extensions for Ruby's `BigDecimal` class.
class BigDecimal
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    to_f.to_s
  end
end

##
# Extensions for Ruby's `Float` class.
class Float
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    case
      when nan? then 'nan.0'
      when infinite? then (infinite? > 0 ? '+inf.0' : '-inf.0')
      else to_s
    end
  end
end

##
# Extensions for Ruby's `Array` class.
class Array
  ##
  # Returns the SXP representation of this object.
  #
  # If array is of the form `[:base, uri, ..]`, the base_uri is taken from the second value
  #
  # If array is of the form `[:prefix, [..], ..]`, prefixes are taken from the second value
  #
  # Prefixes always are terminated by a ':'
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '(' << map { |x| x.to_sxp(prefixes: prefixes, base_uri: base_uri) }.join(' ') << ')'
  end
end

##
# Extensions for Ruby's `Time` class.
class Time
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '#@' << (respond_to?(:xmlschema) ? xmlschema : to_i).to_s
  end
end

##
# Extensions for Ruby's `Regexp` class.
class Regexp
  ##
  # Returns the SXP representation of this object.
  #
  # @param [Hash] prefixes(nil)
  # @param [String] base_uri(nil)
  # @return [String]
  def to_sxp(prefixes: nil, base_uri: nil)
    '#' << inspect
  end
end

begin
  require 'rdf' # For SPARQL/RDF

  ##
  # Extensions for Ruby's `Array` class.
  # These extensions depend on RDF being loaded
  class Array
    ##
    # Returns the SXP representation of this object.
    #
    # If array is of the form `[:base, uri, ..]`, the base_uri is taken from the second value
    #
    # If array is of the form `[:prefix, [..], ..]`, prefixes are taken from the second value
    #
    # Prefixes always are terminated by a ':'
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      if self.first == :base && self.length == 3 && self[1].is_a?(RDF::URI)
        base_uri = self[1]
        '(' << (self[0,2].map(&:to_sxp) << self.last.to_sxp(prefixes: prefixes, base_uri: base_uri)).join(' ') << ')'
      elsif self.first == :prefix && self.length == 3 && self[1].is_a?(Array)
        prefixes = prefixes ? prefixes.dup : {}
        self[1].each do |defn|
          prefixes[defn.first.to_s.chomp(':').to_sym] = RDF::URI(defn.last) if defn.is_a?(Array) && defn.length == 2
        end
        pfx_sxp = self[1].map {|(p,s)|["#{p.to_s.chomp(':')}:".to_sym, RDF::URI(s)]}.to_sxp
        '(' << [:prefix, pfx_sxp, self.last.to_sxp(prefixes: prefixes, base_uri: base_uri)].join(' ') << ')'
      else
        '(' << map { |x| x.to_sxp(prefixes: prefixes, base_uri: base_uri) }.join(' ') << ')'
      end
    end
  end

  class RDF::URI
    ##
    # Returns the SXP representation of this a URI. Uses Lexical representation, if set, otherwise, any PName match, otherwise, the relativized version of the URI if a base_uri is given, otherwise just the URI.
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      return lexical if lexical
      pn = pname(prefixes: prefixes || {})
      return pn unless to_s == pn
      md = self == base_uri ? '' : self.relativize(base_uri)
      "<#{md}>"
    end

    # Original lexical value of this URI to allow for round-trip serialization.
    def lexical=(value); @lexical = value; end
    def lexical; @lexical; end
  end

  class RDF::Node
    ##
    # Returns the SXP representation of this object.
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      to_s
    end
  end

  class RDF::Literal
    ##
    # Returns the SXP representation of a Literal.
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      case datatype
      when RDF::XSD.boolean, RDF::XSD.integer, RDF::XSD.double, RDF::XSD.decimal, RDF::XSD.time
        # Retain stated lexical form if possible
        valid? ? to_s : object.to_sxp
      else
        text = value.dump
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp(prefixes: prefixes, base_uri: base_uri)}" if self.has_datatype?
        text
      end
    end
  end

  class RDF::Query
    # Transform Query into an Array form of an SXP
    #
    # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [Array]
    def to_sxp(prefixes: nil, base_uri: nil)
      res = [:bgp] + patterns
      (named? ? [:graph, graph_name, res] : res).to_sxp(prefixes: prefixes, base_uri: base_uri)
    end
  end

  class RDF::Query::Pattern
    # Transform Query Pattern into an SXP
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      [:triple, subject, predicate, object].to_sxp(prefixes: prefixes, base_uri: base_uri)
    end
  end

  class RDF::Query::Variable
    ##
    # Transform Query variable into an SXP.
    #
    # @param [Hash] prefixes(nil)
    # @param [String] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil)
      to_s
    end
  end
rescue LoadError
  # Ignore if RDF not loaded
end
