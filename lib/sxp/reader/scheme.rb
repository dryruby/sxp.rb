module SXP; class Reader
  ##
  # A Scheme-like S-expression parser.
  class Scheme < Extended
    DECIMAL         = /^[+-]?(\d*)?\.\d*$/.freeze
    INTEGER_BASE_2  = /^[+-]?[01]+$/.freeze
    INTEGER_BASE_8  = /^[+-]?[0-7]+$/.freeze
    INTEGER_BASE_10 = /^[+-]?\d+$/.freeze
    INTEGER_BASE_16 = /^[+-]?[\da-z]+$/i.freeze
    RATIONAL        = /^([+-]?\d+)\/(\d+)$/.freeze

    ##
    # @return [Object]
    def read_token
      case peek_char
        when ?# then [:atom, read_sharp]
        else super
      end
    end

    ##
    # @return [Object]
    def read_atom
      case buffer = read_literal
        when '.'             then buffer.to_sym
        when RATIONAL        then Rational($1.to_i, $2.to_i)
        when DECIMAL         then Float(buffer)
        when INTEGER_BASE_10 then Integer(buffer)
        else buffer.to_sym
      end
    end

    ##
    # @return [Object]
    def read_sharp
      skip_char # '#'
      case char = read_char
        when ?n  then nil    # not in Scheme
        when ?f  then false
        when ?t  then true
        when ?b  then read_integer(2)
        when ?o  then read_integer(8)
        when ?d  then read_integer(10)
        when ?x  then read_integer(16)
        when ?\\ then read_character
        when ?;  then skip; read
        when ?!  then skip_line; read # shebang
        else raise Error, "invalid sharp-sign read syntax: ##{char.chr}"
      end
    end
  end # class Scheme
end; end # class SXP::Reader
