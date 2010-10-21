module SXP; class Reader
  ##
  # A Common Lisp S-expressions parser.
  #
  # @see http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node14.html
  class CommonLisp < Basic
    OPTIONS         = {:nil => nil, :t => true, :quote => :quote, :function => :function}

    DECIMAL         = /^[+-]?(\d*)?\.\d*$/
    INTEGER_BASE_2  = /^[+-]?[01]+$/
    INTEGER_BASE_8  = /^[+-]?[0-7]+$/
    INTEGER_BASE_10 = /^[+-]?\d+$/
    INTEGER_BASE_16 = /^[+-]?[\da-z]+$/i
    RATIONAL        = /^([+-]?\d+)\/(\d+)$/

    # @see http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node22.html
    CHARACTERS = {
      'newline'   => "\n",
      'space'     => " ",
      'backspace' => "\b",   # \010 BS
      'tab'       => "\t",   # \011 HT
      'linefeed'  => "\n",   # \012 LF
      'page'      => "\f",   # \014 FF
      'return'    => "\r",   # \015 CR
      'rubout'    => "\x7F", # \177 DEL
    }

    ##
    # Initializes the reader.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    # @option options [Object]         :nil      (nil)
    # @option options [Object]         :t        (true)
    # @option options [Object]         :quote    (:quote)
    # @option options [Object]         :function (:function)
    def initialize(input, options = {}, &block)
      super(input, OPTIONS.merge(options), &block)
    end

    ##
    # @return [Object]
    def read_token
      case peek_char
        when ?#  then [:atom, read_sharp]
        when ?|  then [:atom, read_symbol(?|)]
        when ?'  then [:atom, read_quote]
        else super
      end
    end

    ##
    # @return [Object]
    def read_sharp
      skip_char # '#'
      case char = read_char
        when ?b, ?B  then read_integer(2)
        when ?o, ?O  then read_integer(8)
        when ?x, ?X  then read_integer(16)
        when ?\\     then read_character
        when ?(      then read_vector
        when ?'      then read_function
        else raise Error, "invalid sharp-sign read syntax: ##{char.chr}"
      end
    end

    ##
    # @return [Symbol]
    def read_symbol(delimiter = nil)
      buffer = String.new
      skip_char # '|'
      until delimiter === peek_char
        buffer <<
          case char = read_char
            when ?\\ then read_character
            else char
          end
      end
      skip_char # '|'
      buffer.to_sym
    end

    ##
    # Reads `#(1 2 3)` forms.
    #
    # @return [Array]
    def read_vector
      raise NotImplementedError, "#{self.class}#read_vector" # TODO
    end

    ##
    # Reads `'foobar` forms.
    #
    # @return [Array]
    def read_quote
      skip_char # "'"
      [options[:quote] || :quote, read]
    end

    ##
    # Reads `#'mapcar` forms.
    #
    # @return [Array]
    def read_function
      [options[:function] || :function, read]
    end

    ##
    # @return [String]
    # @see    http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node22.html
    def read_character
      super
    end

    ##
    # @return [void]
    def skip_comments
      until eof?
        case (char = peek_char).chr
          when /\s+/ then skip_char
          when /;/   then skip_line
          else break
        end
      end
    end
  end # CommonLisp
end; end # SXP::Reader
