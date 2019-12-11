# -*- encoding: utf-8 -*-
module SXP
  ##
  # The base class for S-expression parsers.
  class Reader
    autoload :Basic,      'sxp/reader/basic'
    autoload :Extended,   'sxp/reader/extended'
    autoload :Scheme,     'sxp/reader/scheme'
    autoload :CommonLisp, 'sxp/reader/common_lisp'
    autoload :SPARQL,     'sxp/reader/sparql'

    class Error < StandardError; end
    class EOF < Error; end

    include Enumerable

    ##
    # Reads all S-expressions from a given input URL using the HTTP or FTP
    # protocols.
    #
    # @param  [String, #to_s]          url
    # @param  [Hash{Symbol => Object}] options
    #   See {#read}
    # @return [Enumerable<Object>]
    def self.read_url(url, **options)
      require 'open-uri'
      open(url.to_s, 'rb', nil, **options) { |io| read_all(io, **options) }
    end

    ##
    # Reads all S-expressions from the given input files.
    #
    # @overload read_files(*filenames)
    #   @param  [Enumerable<String>]     filenames
    #
    # @overload read_files(*filenames, **options)
    #   @param  [Enumerable<String>]     filenames
    #   @param  [Hash{Symbol => Object}] options
    #     See {#read}
    #
    # @return [Enumerable<Object>]
    def read_files(*filenames)
      options = filenames.last.is_a?(Hash) ? filenames.pop : {}
      filenames.map { |filename| read_file(filename, **options) }.inject { |sxps, sxp| sxps + sxp }
    end

    ##
    # Reads all S-expressions from a given input file.
    #
    # @param  [String, #to_s]          filename
    # @param  [Hash{Symbol => Object}] options
    #   See {#read}
    # @return [Enumerable<Object>]
    def self.read_file(filename, **options)
      File.open(filename.to_s, 'rb') { |io| read_all(io, **options) }
    end

    ##
    # Reads all S-expressions from the given input stream.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    #   See {#read}
    # @return [Enumerable<Object>]
    def self.read_all(input, **options)
      self.new(input, **options).read_all
    end

    ##
    # Reads one S-expression from the given input stream.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    #   See {#read}
    # @return [Object]
    def self.read(input, **options)
      self.new(input, **options).read
    end

    ##
    # Initializes the reader.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input, **options, &block)
      @options = options.dup

      case
        when [:getc, :ungetc, :eof?].all? { |x| input.respond_to?(x) }
          @input = input
        when input.respond_to?(:to_str)
          require 'stringio' unless defined?(StringIO)
          # NOTE: StringIO#ungetc mutates the string, so we use #dup to take a copy.
          @input = StringIO.new(input.to_str.dup)
          @input.set_encoding('UTF-8') if @input.respond_to?(:set_encoding)
        else
          raise ArgumentError, "expected an IO or String input stream, but got #{input.inspect}"
      end

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else self.instance_eval(&block)
        end
      end
    end

    # @return [Object]
    attr_reader :input

    # @return [Hash]
    attr_reader :options

    ##
    # @yield  [object]
    # @yieldparam [Object] object
    # @return [Enumerator]
    def each(&block)
      unless block_given?
        to_enum
      else
        read_all.each(&block) # TODO: lazy reading
      end
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    #   See {#read}
    # @return [Array]
    def read_all(**options)
      list = []
      catch (:eof) do
        list << read(eof: :throw, **options) until eof?
      end
      list
    end

    ##
    # @param  [Hash{Symbol => Object}] options
    # @option options [:throw] :eof
    #   If `:throw`, throw `:eof` on end of file.
    # @option options [:throw] :eol
    #   If `:throw`, throw `:eol` on end of line.
    # @option options [String] :list_term
    #   Expected list terminator; it's an error
    #   if another terminator is found
    # @return [Object]
    def read(eof: nil, eol: nil, list_term: false, **options)
      skip_comments
      token, value = read_token
      case token
        when :eof
          throw :eof if eof == :throw
          raise EOF, "unexpected end of input"
        when :list
          if ndx = self.class.const_get(:LPARENS).index(value)
            term = self.class.const_get(:RPARENS)[ndx]
            read_list(term)
          else
            throw :eol if eol == :throw && value == list_term
            raise Error, "unexpected list terminator: ?#{value.chr}"
          end
        else value
      end
    end

    alias_method :skip, :read

    ##
    # @param [String] list_term (nil)
    #   String expected to terminate the list
    # @return [Array]
    def read_list(list_term = nil)
      list = []
      catch (:eol) do
        list << read(eol: :throw, list_term: list_term) while true
      end
      list
    end

    ##
    # @return [Object]
    def read_token
      case peek_char
        when nil    then :eof
        else [:atom, read_atom]
      end
    end

    ##
    # @return [Object]
    def read_sharp
      raise NotImplementedError.new("#{self.class}#read_sharp")
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
      raise NotImplementedError.new("#{self.class}#read_atom")
    end

    ##
    # @return [String]
    def read_string
      raise NotImplementedError.new("#{self.class}#read_string")
    end

    ##
    # @return [String]
    def read_character
      raise NotImplementedError.new("#{self.class}#read_character")
    end

    ##
    # @return [String]
    def read_literal
      raise NotImplementedError.new("#{self.class}#read_literal")
    end

  protected

    ##
    # @return [void]
    def skip_comments
      until eof?
        case (char = peek_char).chr
          when /\s+/ then skip_char
          else break
        end
      end
    end

    ##
    # @return [void]
    def skip_line
      loop do
        break if eof? || read_char.chr == $/
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

    alias_method :skip_char, :read_char

    ##
    # @return [String]
    def peek_char
      char = @input.getc
      @input.ungetc(char) unless char.nil?
      char
    end

    ##
    # Unread the string, putting back into the input stream
    # @param [String] string
    def unread(string)
      string.reverse.each_char {|c| @input.ungetc(c)}
    end

    ##
    # @return [Boolean]
    def eof?
      @input.eof?
    end
  end # Reader
end # SXP
