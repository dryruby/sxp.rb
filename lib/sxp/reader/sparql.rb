require 'rdf' # @see http://rubygems.org/gems/rdf

module SXP; class Reader
  ##
  # A SPARQL Syntax Expressions (SSE) parser.
  #
  # Requires [RDF.rb](http://rdf.rubyforge.org/).
  #
  # @see http://openjena.org/wiki/SSE
  class SPARQL < Extended
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
    # @return [Object]
    def read_token
      case peek_char
        when ?" then [:atom, read_rdf_literal] # "
        when ?< then [:atom, read_rdf_uri]
        else super
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
      RDF::URI(buffer)
    end

    ##
    # @return [Object]
    def read_atom
      case buffer = read_literal
        when '.'       then buffer.to_sym
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
