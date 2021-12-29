# -*- encoding: utf-8 -*-
module SXP
  ##
  # An S-expression generator.
  #
  # Takes an object and pretty-prints it using reasonable indentation rules
  class Generator
    ##
    # A basic block containing constituent
    # objects, either blocks or strings.
    class Block
      BLOCK_MIN_LENGTH = 80

      # @attr [Integer] amount of indent applied to this block
      attr_reader :indent

      ##
      # @param [Object] obj
      # @param [Integer] indent
      # @param [Hash{Symbol => RDF::URI}] prefixes (nil)
      # @param [RDF::URI] base_uri (nil)
      def initialize(obj, indent, prefixes: nil, base_uri: nil)
        @indent = indent
        @elements = []
        @prefixes = prefixes
        @base_uri = base_uri
        if obj.is_a?(Array)
          # If this is a base or prefix element, update our representations
          if obj.first == :base && obj.length == 3 && obj[1].is_a?(RDF::URI)
            base_uri = obj[1]
            @elements << Block.new(:base, indent + 1)
            @elements << Block.new(obj[1], indent + 1)
            @elements << Block.new(obj.last, indent + 1, prefixes: prefixes, base_uri: base_uri)
          elsif obj.first == :prefix && obj.length == 3 && obj[1].is_a?(Array)
            prefixes = prefixes ? prefixes.dup : {}
            obj[1].each do |defn|
              prefixes[defn.first.to_s.chomp(':').to_sym] = RDF::URI(defn.last) if defn.is_a?(Array) && defn.length == 2
            end
            @elements << Block.new(:prefix, indent + 1)
            @elements << Block.new(obj[1], indent + 1)
            @elements << Block.new(obj.last, indent + 1, prefixes: prefixes, base_uri: base_uri)
          else          
            obj.compact.each do |o|
              @elements << Block.new(o, indent + 1, prefixes: prefixes, base_uri: base_uri)
            end
          end
        else
          @elements = obj
        end
      end
      
      ##
      # Aggregate length over each element accounting for spaces
      #
      # @return [Integer]
      #   If indent is not not nil, returns zero
      def length
        if @elements.is_a?(Array)
          @elements.map(&:length).inject(:+).to_i + @elements.length - 1
        else
          @elements.to_sxp(prefixes: @prefixes, base_uri: @base_uri).length
        end
      end
      
      ##
      # Turn block into a string in S-expression form
      # This should only be called on a block when
      # no indentation is to be applied
      # @return [String]
      def to_sxp(prefixes: nil, base_uri: nil)
        @elements.to_sxp(prefixes: prefixes || @prefixes, base_uri: base_uri || @base_uri)
      end
      
      ##
      # Determins if this block is an SXP, or not
      # @return [Boolean]
      def sxp?
        @elements.is_a?(Array)
      end

      ##
      # Format block
      # @return [String]
      def formatted
        # Output individual block elements on separate lines
        buffer = ""

        if sxp? && length > BLOCK_MIN_LENGTH
          buffer += do_indent + '('
          first, *elems = @elements
          unless first.sxp?
            # It's atomic, write out after paren
            buffer += first.to_sxp(prefixes: @prefixes, base_uri: @base_uri) + "\n"
          else
            buffer += "\n"
            elems.unshift(first)
          end
          elems.each do |e|
            buffer += e.formatted
          end
          buffer += do_indent + ")\n"
        else
          buffer += do_indent + @elements.to_sxp(prefixes: @prefixes, base_uri: @base_uri) + "\n"
        end
        buffer
      end
      
      private
      def do_indent(offset = 0); ' ' * (indent + offset); end
    end

    ##
    # Format S-expressions to a String
    #
    # @param  [Array]  sxps
    # @return [Object]
    def self.string(*sxps)
      require 'stringio' unless defined?(StringIO)
      buf = StringIO.new
      write(buf, *sxps)
      buf.string
    end

    ##
    # Format S-expressions to STDOUT
    #
    # @param  [Array]  sxps
    # @return [Object]
    def self.print(*sxps)
      write($stdout, *sxps)
    end

    ##
    # Write formatted S-expressions to an IO like object
    #
    # @param  [Object] out
    # @param  [Array]  sxps
    # @return [Object]
    def self.write(out, *sxps)
      generator = self.new(out)
      sxps.each do |sxp|
        generator.render(sxp)
      end
      generator
    end

    ##
    # Initialize output with a stack of IO buffers
    #
    # @param  [#write] buffer
    def initialize(buffer)
      @output = buffer
    end

    ##
    # Render an element.
    # For Array, this recursively renders each constituent into blocks.
    # If the agregate length of a block is less than MIN_BLOCK characters,
    # combine each constituent block into a single line.
    #
    # Rendering does not perform final formatting, but returns a recursive
    # array of blocks which are each ultimattely formattted onto their
    # own line with leading whitespace.
    #
    # @param [Object] sexp
    # @return [Block]
    def render(sexp)
      block = Block.new(sexp, 0)
      if block.length > 40
        buffer = block.formatted

        # Attempt to fold symbols and strings onto proceeding line
        output = ""
        prev_length = 0
        buffer.lines.each do |line|
          if (stripped = line.strip)[0,1] != '(' &&
            prev_length + stripped.length + 1 < Block::BLOCK_MIN_LENGTH

            # Append to previous line
            start, match, rem = output.rpartition(/\S/)
            output = start + match + " " + stripped + rem
            prev_length += stripped.length + 1
          else
            # Terminate line and append this line
            output += line
            prev_length = line.length - 1
          end
        end
        @output.write output.gsub(/\)\s+\)/, '))')
      else
        @output.puts(block.to_sxp)
      end
    end
  end # Generator
end # SXP
