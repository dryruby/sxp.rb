module SXP; class Reader
  ##
  # A Common Lisp S-expressions parser.
  class CommonLisp < Basic
    ##
    # Initializes the reader.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    # @option options [Object]         :t   (:t)
    # @option options [Object]         :nil (:nil)
    def initialize(input, options = {}, &block)
      super(input, {:t => :t, :nil => :nil}.merge(options), &block)
    end

    ##
    # @return [Object]
    def read_token
      case peek_char
        when false # TODO
        else super
      end
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
  end # class CommonLisp
end; end # class SXP::Reader
