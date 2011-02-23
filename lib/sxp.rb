require 'rational'
require 'stringio'

if RUBY_VERSION < '1.8.7'
  # @see http://rubygems.org/gems/backports
  begin
    require 'backports/1.8.7'
  rescue LoadError
    begin
      require 'rubygems'
      require 'backports/1.8.7'
    rescue LoadError
      abort "SXP.rb requires Ruby 1.8.7 or the Backports gem (hint: `gem install backports')."
    end
  end
end

require 'sxp/version'
require 'sxp/extensions'
require 'sxp/writer'

module SXP
  autoload :Pair,      'sxp/pair'
  autoload :List,      'sxp/list'
  autoload :Generator, 'sxp/generator'
  autoload :Reader,    'sxp/reader'

  ##
  # Reads all S-expressions from a given input URL using the HTTP or FTP
  # protocols.
  #
  # @param  [String, #to_s]          url
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_url(url, options = {})
    Reader::Scheme.read_url(url, options)
  end

  ##
  # Reads all S-expressions from the given input files.
  #
  # @param  [Enumerable<String>]     filenames
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_files(*filenames)
    Reader::Scheme.read_files(*filenames)
  end

  ##
  # Reads all S-expressions from a given input file.
  #
  # @param  [String, #to_s]          filename
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_file(filename, options = {})
    Reader::Scheme.read_file(filename, options)
  end

  ##
  # Reads all S-expressions from the given input stream.
  #
  # @param  [IO, StringIO, String]   input
  # @param  [Hash{Symbol => Object}] options
  # @return [Enumerable<Object>]
  def self.read_all(input, options = {})
    Reader::Scheme.read_all(input, options)
  end

  ##
  # Reads one S-expression from the given input stream.
  #
  # @param  [IO, StringIO, String]   input
  # @param  [Hash{Symbol => Object}] options
  # @return [Object]
  def self.read(input, options = {})
    Reader::Scheme.read(input, options)
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
end # SXP
