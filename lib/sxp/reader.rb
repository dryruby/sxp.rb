module SXP

  # Reads one S-expression from the given input stream.
  def self.read(input)
    Reader.new(input).read
  end

  # Reads all S-expressions from the given input stream.
  def self.read_all(input)
    Reader.new(input).read_all
  end

  # Reads all S-expressions from a given input file.
  def self.read_file(filename)
    File.open(filename, 'rb') { |io| read_all(io) }
  end

  # Reads all S-expressions from a given input URI using the HTTP or FTP protocols.
  def self.read_uri(uri, options = {})
    require 'openuri'
    open(uri, 'rb', nil, options) { |io| read_all(io) }
  end

  class <<self
    alias_method :parse, :read
    alias_method :parse_all, :read_all
    alias_method :parse_file, :read_file
    alias_method :parse_uri, :read_uri
  end

  class Reader
    include Enumerable

    class Error < StandardError; end
    class EOF < Error; end

    FLOAT           = /^[+-]?(?:\d+)?\.\d*$/
    INTEGER_BASE_2  = /^[+-]?[01]+$/
    INTEGER_BASE_8  = /^[+-]?[0-7]+$/
    INTEGER_BASE_10 = /^[+-]?\d+$/
    INTEGER_BASE_16 = /^[+-]?[\da-z]+$/i
    RATIONAL        = /^([+-]?\d+)\/(\d+)$/
    ATOM            = /^[^\s()]+/

    attr_reader :input

    def initialize(input)
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

    def each(&block)
      block.call(read)
    end

    def read_all(options = {})
      list = []
      catch (:eof) { list << read(:eof => :throw, *options) until eof? }
      list
    end

    def read(options = {})
      token, value = read_token
      case token
        when :eof
          throw :eof if options[:eof] == :throw
          raise EOF, 'unexpected end of input'
        when :list
          if value == ?(
            read_list
          else
            throw :eol if options[:eol] == :throw
            raise Error, 'unexpected list terminator: ?)'
          end
        else value
      end
    end

    alias skip read

    def read_token
      skip_comments
      case peek_char
        when nil then :eof
        when ?(, ?) then [:list, read_char]
        when ?# then [:atom, read_sharp]
        when ?" then [:atom, read_string]
        else [:atom, read_atom]
      end
    end

    def read_list
      list = []
      catch (:eol) { list << read(:eol => :throw) while true }
      list
    end

    def read_sharp
      skip_char # '#'
      case char = read_char
        when ?n then nil
        when ?f then false
        when ?t then true
        when ?b then read_integer(2)
        when ?o then read_integer(8)
        when ?d then read_integer(10)
        when ?x then read_integer(16)
        when ?\\ then read_character
        when ?; then skip; read
        else raise Error, "invalid sharp-sign read syntax: ##{char.chr}"
      end
    end

    def read_integer(base = 10)
      case buffer = read_literal
        when self.class.const_get(:"INTEGER_BASE_#{base}")
          buffer.to_i(base)
        else raise Error, "illegal base-#{base} number syntax: #{buffer}"
      end
    end

    def read_atom
      case buffer = read_literal
        when FLOAT then buffer.to_f
        when INTEGER_BASE_10 then buffer.to_i
        when RATIONAL then Rational($1.to_i, $2.to_i)
        else buffer.to_sym
      end
    end

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

    def read_literal
      buffer = String.new
      buffer << read_char while !eof? && peek_char.chr =~ ATOM
      buffer
    end

    def skip_comments
      until eof?
        case (char = peek_char).chr
          when /;/ then loop { break if eof? || read_char.chr == $/ }
          when /\s+/ then skip_char
          else break
        end
      end
    end

    def read_chars(count = 1)
      buffer = ''
      count.times { buffer << read_char.chr }
      buffer
    end

    def read_char
      char = @input.getc
      raise EOF, 'unexpected end of input' if char.nil?
      char
    end

    alias skip_char read_char

    def peek_char
      char = @input.getc
      @input.ungetc char unless char.nil?
      char
    end

    def eof?() @input.eof? end
  end

end
