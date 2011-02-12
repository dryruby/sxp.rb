require 'rdf' # @see http://rubygems.org/gems/rdf

module SXP; class Reader
  ##
  # A SPARQL Syntax Expressions (SSE) parser.
  #
  # Requires [RDF.rb](http://rdf.rubyforge.org/).
  #
  # @see http://openjena.org/wiki/SSE
  class SPARQL < Extended
    BASE      = /^base$/i
    PREFIX    = /^prefix$/i
    NIL       = /^nil$/i
    FALSE     = /^false$/i
    TRUE      = /^true$/i
    EXPONENT  = /[eE][+-]?[0-9]+/
    DECIMAL   = /^[+-]?(\d*)?\.\d*#{EXPONENT}?$/
    BNODE_ID  = /^_:([A-Za-z][A-Za-z0-9]*)/ # FIXME
    BNODE_NEW = /^_:$/
    VAR_ID    = /^\?([A-Za-z][A-Za-z0-9]*)/ # FIXME
    VAR_GEN   = /^\?\?([0-9]+)/
    VAR_NEW   = '??'
    URIREF    = /^<([^>]+)>/

    ##
    # Base URI as specified or when parsing parsing a BASE token using the immediately following
    # token, which must be a URI.
    attr_accessor :base_uri

    ##
    # Defines the given named URI prefix for this parser.
    #
    # @example Defining a URI prefix
    #   parser.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   parser.prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @overload prefix(name, uri)
    #   @param  [Symbol, #to_s]   name
    #   @param  [RDF::URI, #to_s] uri
    #
    # @overload prefix(name)
    #   @param  [Symbol, #to_s]   name
    #
    # @return [RDF::URI]
    def prefix(name, uri = nil)
      name = name.to_s.empty? ? nil : (name.respond_to?(:to_sym) ? name.to_sym : name.to_s.to_sym)
      uri.nil? ? @prefixes[name] : @prefixes[name] = uri
    end

    ##
    # Initializes the reader.
    #
    # @param  [IO, StringIO, String]   input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input, options = {}, &block)
      super { @prefixes = {} }

      if block_given?
        case block.arity
          when 1 then block.call(self)
          else self.instance_eval(&block)
        end
      end
    end

    ##
    # @return [Object]
    def read_token
      case peek_char
      when ?" then [:atom, read_rdf_literal] # "
      when ?< then [:atom, read_rdf_uri]
      else
        tok = super
        
        # If we just parsed "PREFIX", use this token for associating a URI
        # This is used again when we actually parse the URI
        if tok.is_a?(Array) && tok[0] == :atom && tok[1].is_a?(Symbol)
          value = tok[1].to_s

          # We previously parsed a PREFIX, this will be the map value
          @parsed_prefix = value.chop if @parsed_prefix == true
          @parsed_prefix = true if value =~ PREFIX
          
          # If the token is of the form 'prefix:suffix', create a URI and give it the
          # token as a QName
          if value.to_s =~ /([^:]*):([^:]*)/ && base = prefix($1)
            suffix = $2
            #STDERR.puts "read_tok qname: pfx: #{$1.inspect} => #{prefix($1).inspect}, sfx: #{suffix.inspect}"
            suffix = suffix.sub(/^\#/, "") if base.to_s.index("#")
            uri = RDF::URI(base.to_s + suffix)
            #STDERR.puts "read_tok qname uri: #{uri.inspect}"

            # Cause URI to be serialized as a qname
            uri.qname = value
            [:atom, uri]
          else
            tok
          end
        else
          tok
        end
      end
    end

    ##
    # @return [RDF::Literal]
    def read_rdf_literal
      value   = read_string
      options = case peek_char
        when ?@
          skip_char # '@'
          {:language => read_atom}
        when ?^
          2.times { skip_char } # '^^'
          {:datatype => read_rdf_uri} # TODO: support prefixed names
        else {}
      end
      RDF::Literal(value, options)
    end

    ##
    # @return [RDF::URI]
    def read_rdf_uri
      buffer = String.new
      skip_char # '<'
      return :< if (char = peek_char).nil? || char.chr !~ ATOM # FIXME: nasty special case for the '< symbol
      return :<= if peek_char.chr.eql?(?=.chr) && read_char    # FIXME: nasty special case for the '<= symbol
      until peek_char == ?>
        buffer << read_char # TODO: unescaping
      end
      skip_char # '>'

      # If we have a base URI, use that when constructing a new URI
      uri = self.base_uri ? self.base_uri.join(buffer) : RDF::URI(buffer)
      
      # If we previously parsed a "BASE" element, then this URI is used to set that value
      if @parsed_base
        self.base_uri = uri
        @parsed_base = nil
      end
      
      # If we previously parsed a "PREFIX" element, associate this URI with the prefix
      if @parsed_prefix
        prefix(@parsed_prefix, uri)
        @parsed_prefix = nil
      end
      
      uri
    end

    ##
    # @return [Object]
    def read_atom
      case buffer = read_literal
        when '.'       then buffer.to_sym
        when BASE      then @parsed_base = true; buffer.to_sym
        when NIL       then nil
        when FALSE     then RDF::Literal(false)
        when TRUE      then RDF::Literal(true)
        when DECIMAL   then RDF::Literal(Float(buffer[-1].eql?(?.) ? buffer + '0' : buffer))
        when INTEGER   then RDF::Literal(Integer(buffer))
        when BNODE_ID  then RDF::Node($1)
        when BNODE_NEW then RDF::Node.new
        when VAR_ID    then RDF::Query::Variable.new($1)
        when VAR_GEN   then RDF::Query::Variable.new("?#{$1}") # FIXME?
        when VAR_NEW   then RDF::Query::Variable.new
        else buffer.to_sym
      end
    end

    ##
    # @return [void]
    def skip_comments
      until eof?
        case (char = peek_char).chr
          when /\s+/ then skip_char
          when /;/   then skip_line
          when /#/   then skip_line
          else break
        end
      end
    end
  end # SPARQL
end; end # SXP::Reader
