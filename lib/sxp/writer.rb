class Object
  def to_sxp
    to_s.to_json
  end
end

class NilClass
  def to_sxp; '#n'; end
end

class FalseClass
  def to_sxp; '#f'; end
end

class TrueClass
  def to_sxp; '#t'; end
end

class String
  def to_sxp; inspect; end
end

class Symbol
  def to_sxp; to_s; end
end

class Integer
  def to_sxp; to_s; end
end

class Float
  def to_sxp
    case
      when nan? then 'nan.'
      when infinite? then (infinite? > 0 ? '+inf.' : '-inf.')
      else to_s
    end
  end
end

class Array
  def to_sxp
    '(' << map { |x| x.to_sxp }.join(' ') << ')'
  end
end

class Time
  def to_sxp
    '#@' << (respond_to?(:xmlschema) ? xmlschema : to_i).to_s
  end
end

class Regexp
  def to_sxp
    '#' << inspect
  end
end
