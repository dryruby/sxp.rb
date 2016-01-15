# -*- encoding: utf-8 -*-
require 'bigdecimal'
require 'time'

##
# Extensions for Ruby's `Object` class.
class Object
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp
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
  def to_sxp
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
  def to_sxp
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
  def to_sxp
    '#t'
  end
end

##
# Extensions for Ruby's `String` class.
class String
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp
    inspect
  end
end

##
# Extensions for Ruby's `Symbol` class.
class Symbol
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp
    to_s
  end
end

##
# Extensions for Ruby's `Integer` class.
class Integer
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp
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
  def to_sxp
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
  def to_sxp
    case
      when nan? then 'nan.'
      when infinite? then (infinite? > 0 ? '+inf.' : '-inf.')
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
  def to_sxp
    '(' << map { |x| x.to_sxp }.join(' ') << ')'
  end
end

##
# Extensions for Ruby's `Time` class.
class Time
  ##
  # Returns the SXP representation of this object.
  #
  # @return [String]
  def to_sxp
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
  def to_sxp
    '#' << inspect
  end
end

begin
  require 'rdf' # For SPARQL

  class RDF::URI
    ##
    # Returns the SXP representation of this object.
    #
    # @return [String]
    def to_sxp; lexical || "<#{self}>"; end
  end

  class RDF::Node
    ##
    # Returns the SXP representation of this object.
    #
    # @return [String]
    def to_sxp; to_s; end
  end

  class RDF::Literal
    ##
    # Returns the SXP representation of a Literal.
    #
    # @return [String]
    def to_sxp
      case datatype
      when RDF::XSD.boolean, RDF::XSD.integer, RDF::XSD.double, RDF::XSD.decimal, RDF::XSD.time
        # Retain stated lexical form if possible
        valid? ? to_s : object.to_sxp
      else
        text = value.dump
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp}" if self.has_datatype?
        text
      end
    end
  end

  class RDF::Query
    # Transform Query into an Array form of an SXP
    #
    # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
    #
    # @return [Array]
    def to_sxp
      res = [:bgp] + patterns
      (named? ? [:graph, graph_name, res] : res).to_sxp
    end
  end

  class RDF::Query::Pattern
    # Transform Query Pattern into an SXP
    # @return [String]
    def to_sxp
      [:triple, subject, predicate, object].to_sxp
    end
  end

  class RDF::Query::Variable
    def to_sxp; to_s; end
  end
rescue LoadError => e
  # Ignore if RDF not loaded
end