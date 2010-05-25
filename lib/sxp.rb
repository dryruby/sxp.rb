require 'sxp/version'
require 'sxp/extensions'
require 'sxp/writer'

module SXP
  autoload :Pair,      'sxp/pair'
  autoload :List,      'sxp/list'
  autoload :Generator, 'sxp/generator'
  autoload :Reader,    'sxp/reader'

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
end # module SXP
