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
