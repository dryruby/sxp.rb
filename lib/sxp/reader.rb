module SXP
  ##
  # Reads all S-expressions from a given input URI using the HTTP or FTP
  # protocols.
  #
  # @param  [String, #to_s]          url
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_url(url, options = {})
    require 'openuri'
    open(url.to_s, 'rb', nil, options) { |io| read_all(io, options) }
  end

  ##
  # Reads all S-expressions from the given input files.
  #
  # @param  [Enumerable<String>]     filenames
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_files(*filenames)
    options = filenames.last.is_a?(Hash) ? filenames.pop : {}
    filenames.map { |filename| read_file(filename, options) }.inject { |sxps, sxp| sxps + sxp }
  end

  ##
  # Reads all S-expressions from a given input file.
  #
  # @param  [String, #to_s]          filename
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_file(filename, options = {})
    File.open(filename.to_s, 'rb') { |io| read_all(io, options) }
  end

  ##
  # Reads all S-expressions from the given input stream.
  #
  # @param  [IO, StringIO, String]   input
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_all(input, options = {})
    Reader.new(input, options).read_all
  end

  ##
  # Reads one S-expression from the given input stream.
  #
  # @param  [IO, StringIO, String]   input
  # @param  [Hash{Symbol => Object}] options
  # @return [Object]
  def self.read(input, options = {})
    Reader.new(input, options).read
  end

  class << self
    alias_method :parse,       :read
    alias_method :parse_all,   :read_all
    alias_method :parse_files, :read_files
    alias_method :parse_file,  :read_file
    alias_method :parse_url,   :read_url
    alias_method :parse_uri,   :read_url # @deprecated
    alias_method :read_uri,    :read_url # @deprecated
  end

  ##
  # The base class for S-expression parsers.
  class Reader
    include Enumerable

    class Error < StandardError; end
    class EOF < Error; end

    FLOAT           = /^[+-]?(\d*)?\.\d*$/
    INTEGER_BASE_2  = /^[+-]?[01]+$/
    INTEGER_BASE_8  = /^[+-]?[0-7]+$/
    INTEGER_BASE_10 = /^[+-]?\d+$/
    INTEGER_BASE_16 = /^[+-]?[\da-z]+$/i
    RATIONAL        = /^([+-]?\d+)\/(\d+)$/
    ATOM            = /^[^\s()\[\]]+/

    # @return [Object]
    attr_reader :input

    ##
    # @param  [Object] input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input, options = {})
      case
        when [:getc, :ungetc, :eof?].all? { |x| input.respond_to?(x) }
          @input = input
        when input.respond_to?(:to_str)
          require 'stringio'
          @input = StringIO.new(input.to_str)
        else
          raise ArgumentError, "expected an IO or String input stream: #{input.inspect}"
      end
    end

    ##
    # @yield  [object]
    # @yieldparam [Object] object
    # @return [Enumerator]
    def each(&block)
      block.call(read) if block_given? # FIXME
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    # @return [Array]
    def read_all(options = {})
      list = []
      catch (:eof) do
        list << read(options.merge(:eof => :throw)) until eof?
      end
      list
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    # @return [Object]
    def read(options = {})
      skip_comments
      token, value = read_token
      case token
        when :eof
          throw :eof if options[:eof] == :throw
          raise EOF, 'unexpected end of input'
        when :list
          if value == ?( || value == ?[
            read_list
          else
            throw :eol if options[:eol] == :throw # end of list
            raise Error, "unexpected list terminator: ?#{value.chr}"
          end
        else value
      end
    end

    alias_method :skip, :read

    ##
    # @return [Object]
    def read_token
      case peek_char
        when nil    then :eof
        when ?(, ?) then [:list, read_char]
        when ?[, ?] then [:list, read_char]
        when ?"     then [:atom, read_string]
        when ?#     then [:atom, read_sharp]
        else [:atom, read_atom]
      end
    end

    ##
    # @param [Array]
    def read_list
      list = []
      catch (:eol) do
        list << read(:eol => :throw) while true
      end
      list
    end

    ##
    # @return [Object]
    def read_sharp
      skip_char # '#'
      case char = read_char
        when ?n  then nil
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

    ##
    # @param  [Integer] base
    # @return [Integer]
    def read_integer(base = 10)
      case buffer = read_literal
        when self.class.const_get(:"INTEGER_BASE_#{base}")
          buffer.to_i(base)
        else raise Error, "illegal base-#{base} number syntax: #{buffer}"
      end
    end

    ##
    # @return [Object]
    def read_atom
      case buffer = read_literal
        when '.'             then buffer.to_sym
        when FLOAT           then buffer.to_f
        when INTEGER_BASE_10 then buffer.to_i
        when RATIONAL        then Rational($1.to_i, $2.to_i)
        else buffer.to_sym
      end
    end

    ##
    # @return [String]
    def read_string
      buffer = String.new
      skip_char # '"'
      until peek_char == ?"
        buffer <<
          case char = read_char
            when ?\\ then read_character
            else char
          end
      end
      skip_char # '"'
      buffer
    end

    ##
    # @return [String]
    def read_character
      case char = read_char
        when ?b then ?\b
        when ?f then ?\f
        when ?n then ?\n
        when ?r then ?\r
        when ?t then ?\t
        when ?u then read_chars(4).to_i(16).chr
        when ?U then read_chars(8).to_i(16).chr
        else char
      end
    end

    ##
    # @return [String]
    def read_literal
      buffer = String.new
      buffer << read_char while !eof? && peek_char.chr =~ ATOM
      buffer
    end

    ##
    # @return [void]
    def skip_comments
      until eof?
        case (char = peek_char).chr
          when /;/   then skip_line
          when /\s+/ then skip_char
          else break
        end
      end
    end

    ##
    # @param  [Integer] count
    # @return [String]
    def read_chars(count = 1)
      buffer = ''
      count.times { buffer << read_char.chr }
      buffer
    end

    ##
    # @return [String]
    def read_char
      char = @input.getc
      raise EOF, 'unexpected end of input' if char.nil?
      char
    end

    ##
    # @return [void]
    def skip_line
      loop do
        break if eof? || read_char.chr == $/
      end
    end

    alias_method :skip_char, :read_char

    ##
    # @return [String]
    def peek_char
      char = @input.getc
      @input.ungetc char unless char.nil?
      char
    end

    ##
    # @return [Boolean]
    def eof?
      @input.eof?
    end
  end # class Reader
end # module SXP
