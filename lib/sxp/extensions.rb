# -*- encoding: utf-8 -*-
require 'bigdecimal'
require 'matrix'
require 'time'

##
# Extensions for Ruby's `Object` class.
class Object
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    to_s.to_json
  end
end

##
# Extensions for Ruby's `NilClass` class.
class NilClass
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    '#n'
  end
end

##
# Extensions for Ruby's `FalseClass` class.
class FalseClass
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    '#f'
  end
end

##
# Extensions for Ruby's `TrueClass` class.
class TrueClass
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    '#t'
  end
end

##
# Extensions for Ruby's `String` class.
class String
  ##
  # Returns the SXP representation of this object. Uses SPARQL-like escaping.
  # Uses any recorded quote style from an originally parsed string.
  #
  # @return [String]
  def to_sxp(**options)
    buffer = ""
    each_char do |u|
      buffer << case u.ord
      when (0x00..0x07) then sprintf("\\u%04X", u.ord)
      when (0x08)       then '\b'
      when (0x09)       then '\t'
      when (0x0A)       then '\n'
      when (0x0C)       then '\f'
      when (0x0D)       then '\r'
      when (0x0E..0x1F) then sprintf("\\u%04X", u.ord)
      when (0x22)       then as_dquote? ? '\"' : '"'
      when (0x27)       then as_squote? ? "\'" : "'"
      when (0x5C)       then '\\\\'
      when (0x7F)       then sprintf("\\u%04X", u.ord)
      else u.chr
      end
    end
    if as_dquote?
      '"' + buffer + '"'
    else
      "'" + buffer + "'"
    end
  end

  # Record quote style used when parsing
  # @return [:dquote, :squote]
  attr_accessor :quote_style

  # Render string using double quotes
  def as_squote?; quote_style == :squote; end

  # Render string using single quotes
  def as_dquote?; quote_style != :squote; end
end

##
# Extensions for Ruby's `Symbol` class.
class Symbol
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
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
  # @return [String]
  def to_sxp(**options)
    to_s
  end
end

##
# Extensions for Ruby's `BigDecimal` class.
class BigDecimal
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    to_f.to_s
  end
end

##
# Extensions for Ruby's `Float` class.
class Float
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
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
  # @return [String]
  def to_sxp()
    '(' << map { |x| x.to_sxp(**options) }.join(' ') << ')'
  end
end

##
# Extensions for Ruby's `Vector` class.
class Vector
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    '#(' << to_a.map { |x| x.to_sxp(**options) }.join(' ') << ')'
  end
end

##
# Extensions for Ruby's `Hash` class.
class Hash
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    to_a.to_sxp(**options)
  end
end

##
# Extensions for Ruby's `Time` class.
class Time
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
    '#@' << (respond_to?(:xmlschema) ? xmlschema : to_i).to_s
  end
end

##
# Extensions for Ruby's `Regexp` class.
class Regexp
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp(**options)
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
    # @param [Hash{Symbol => RDF::URI}] prefixes(nil)
    # @param [RDF::URI] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil, **options)
      if self.first == :base && self.length == 3 && self[1].is_a?(RDF::URI)
        base_uri = self[1]
        '(' << (
        self[0,2].map(&:to_sxp) <<
          self.last.to_sxp(prefixes: prefixes, base_uri: base_uri, **options)
        ).join(' ') << ')'
      elsif self.first == :prefix && self.length == 3 && self[1].is_a?(Array)
        prefixes = prefixes ? prefixes.dup : {}
        self[1].each do |defn|
          prefixes[defn.first.to_s.chomp(':').to_sym] = RDF::URI(defn.last) if
            defn.is_a?(Array) && defn.length == 2
        end
        pfx_sxp = self[1].map {|(p,s)|["#{p.to_s.chomp(':')}:".to_sym, RDF::URI(s)]}.to_sxp
        '(' << [
          :prefix,
          pfx_sxp,
          self.last.to_sxp(prefixes: prefixes, base_uri: base_uri, **options)
        ].join(' ') << ')'
      else
        '(' << map { |x| x.to_sxp(prefixes: prefixes, base_uri: base_uri, **options) }.join(' ') << ')'
      end
    end
  end

  class RDF::URI
    ##
    # Returns the SXP representation of this URI. Uses Lexical representation, if set, otherwise, any PName match, otherwise, the relativized version of the URI if a base_uri is given, otherwise just the URI.
    #
    # @param [Hash{Symbol => RDF::URI}] prefixes(nil)
    # @param [RDF::URI] base_uri(nil)
    # @return [String]
    def to_sxp(prefixes: nil, base_uri: nil, **options)
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
    # @return [String]
    def to_sxp(**options)
      to_s
    end
  end

  class RDF::Literal
    ##
    # Returns the SXP representation of a Literal.
    #
    # @return [String]
    def to_sxp(**options)
      case datatype
      when RDF::XSD.boolean, RDF::XSD.integer, RDF::XSD.double, RDF::XSD.decimal
        # Retain stated lexical form if possible
        valid? ? to_s : object.to_sxp(**options)
      else
        text = value.to_sxp
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp(**options)}" if self.has_datatype?
        text
      end
    end

    class Double
      ##
      # Returns the SXP representation of this object.
      #
      # @return [String]
      def to_sxp(**options)
        case
          when nan? then 'nan.0'
          when infinite? then (infinite? > 0 ? '+inf.0' : '-inf.0')
          else canonicalize.to_s.downcase
        end
      end
    end
  end

  class RDF::Query
    # Transform Query into an Array form of an SXP
    #
    # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
    #
    # @return [Array]
    def to_sxp(**options)
      res = [:bgp] + patterns
      (named? ? [:graph, graph_name, res] : res).to_sxp(**options)
    end
  end

  class RDF::Query::Pattern
    # Transform Query Pattern into an SXP
    #
    # @return [String]
    def to_sxp(**options)
      [:triple, subject, predicate, object].to_sxp(**options)
    end
  end

  class RDF::Query::Variable
    ##
    # Transform Query variable into an SXP.
    #
    # @return [String]
    def to_sxp(**options)
      prefix = distinguished? ? (existential? ? '$' : '?') : (existential? ? '$$' : '??')
      unbound? ? "#{prefix}#{name}".to_sym.to_sxp : ["#{prefix}#{name}".to_sym, value].to_sxp
    end
  end
rescue LoadError
  # Ignore if RDF not loaded
end
