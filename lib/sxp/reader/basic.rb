# -*- encoding: utf-8 -*-
module SXP; class Reader
  ##
  # A basic S-expression parser.
  class Basic < Reader
    LPARENS  = [?(]
    RPARENS  = [?)]
    ATOM     = /^[^\s()]+/
    RATIONAL = /^([+-]?\d+)\/(\d+)$/
    DECIMAL  = /^[+-]?(\d*)?\.\d*$/
    INTEGER  = /^[+-]?\d+$/

    ##
    # @return [Object]
    def read_token
      case peek_char
        when ?(, ?) then [:list, read_char]
        when ?", ?' then [:atom, read_string] #" or '
        else super
      end
    end

    ##
    # @return [Object]
    def read_atom
      case buffer = read_literal
        when '.'      then buffer.to_sym
        when RATIONAL then Rational($1.to_i, $2.to_i)
        when DECIMAL  then Float(buffer.end_with?('.') ? "#{buffer}0" : buffer)
        when INTEGER  then Integer(buffer)
        else buffer.to_sym
      end
    end

    ##
    # @return [String]
    def read_string
      buffer = ""
      quote_char = read_char
      until peek_char == quote_char # " or '
        buffer <<
          case char = read_char
            when ?\\ then read_character
            else char
          end
      end
      skip_char # " or '

      # Return string, annotating it with the quotation style used
      buffer.tap {|s| s.quote_style = (quote_char == '"' ? :dquote : :squote)}
    end

    ##
    # @return [String]
    def read_character
      case char = read_char
        when ?b  then ?\b
        when ?f  then ?\f
        when ?n  then ?\n
        when ?r  then ?\r
        when ?t  then ?\t
        when ?u  then read_chars(4).to_i(16).chr(Encoding::UTF_8)
        when ?U  then read_chars(8).to_i(16).chr(Encoding::UTF_8)
        when ?"  then char #"
        when ?\\ then char
        else char
      end
    end

    ##
    # @return [String]
    def read_literal
      grammar = self.class.const_get(:ATOM)
      buffer = ""
      buffer << read_char while !eof? && peek_char.chr =~ grammar
      buffer
    end
  end # Basic
end; end # SXP::Reader
