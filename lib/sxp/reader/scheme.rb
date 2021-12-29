# -*- encoding: utf-8 -*-
module SXP; class Reader
  ##
  # A Scheme R4RS S-expressions parser.
  #
  # @see https:/people.csail.mit.edu/jaffer/r4rs_9.html#SEC65
  class Scheme < Extended
    DECIMAL         = /^[+-]?(\d*)?\.\d*$/
    INTEGER_BASE_2  = /^[+-]?[01]+$/
    INTEGER_BASE_8  = /^[+-]?[0-7]+$/
    INTEGER_BASE_10 = /^[+-]?\d+$/
    INTEGER_BASE_16 = /^[+-]?[\da-z]+$/i
    RATIONAL        = /^([+-]?\d+)\/(\d+)$/

    # Escape characters, used in the form `#\newline`. Case is treated
    # insensitively
    # @see https:/people.csail.mit.edu/jaffer/r4rs_9.html#SEC65
    CHARACTERS = {
      'newline'   => "\n",
      'space'     => " ",
    }

    ##
    # Initializes the reader.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    # @option options [Symbol]         :version (:r4rs)
    def initialize(input, version: :r4rs, **options, &block)
      super(input, version: version, **options, &block)
    end

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
        when ?n, ?N  then nil    # not in Scheme per se
        when ?f, ?F  then false
        when ?t, ?T  then true
        when ?b, ?B  then read_integer(2)
        when ?o, ?O  then read_integer(8)
        when ?d, ?D  then read_integer(10)
        when ?x, ?X  then read_integer(16)
        when ?\\     then read_character
        when ?;      then skip # comment character
        when ?!      then skip_line; skip # shebang
        else raise Error, "invalid sharp-sign read syntax: ##{char.chr}"
      end
    end

    ##
    # Read characters sequences like `#\space`. Otherwise,
    # reads a single character. Requires the ability to put
    # eroneously read characters back in the input stream
    #
    # @return [String]
    # @see    https:/people.csail.mit.edu/jaffer/r4rs_9.html#SEC65
    def read_character
      lit = read_literal

      return " " if lit.empty? && peek_char == " "
      CHARACTERS.fetch(lit.downcase) do
        # Return just the first character
        unread(lit[1..-1])
        lit[0,1]
      end
    end
  end # Scheme
end; end # SXP::Reader
