module SXP
  ##
  # An S-expression generator.
  class Generator
    ##
    # @param  [Array]  sxps
    # @return [Object]
    def self.string(*sxps)
      require 'stringio' unless defined?(StringIO)
      write(StringIO.new, *sxps).instance_variable_get('@buffer').string
    end

    ##
    # @param  [Array]  sxps
    # @return [Object]
    def self.print(*sxps)
      write($stdout, *sxps)
    end

    ##
    # @param  [Object] out
    # @param  [Array]  sxps
    # @return [Object]
    def self.write(out, *sxps)
      generator = self.new(out)
      sxps.each do |sxp|
        generator.send((op = sxp.shift).to_sym, *sxp)
      end
      generator
    end

    ##
    # @param  [Object] buffer
    def initialize(buffer)
      @output = [@buffer = buffer]
      @indent = 0
    end

    protected

    ##
    # @param  [String]                 text
    # @param  [Hash{Symbol => Object}] options
    # @return [void]
    def emit(text, options = {})
      if out = @output.last
        out.print(' ' * (indent * 2)) if options[:indent]
        out.print(text)
      end
    end

    ##
    # @yield
    # @return [String]
    def captured(&block)
      require 'stringio' unless defined?(StringIO)
      begin
        @output.push(buffer = StringIO.new)
        block.call
      ensure
        @output.pop
      end
      buffer.string
    end

    ##
    # @yield
    # @return [Object]
    def indented(&block)
      begin
        increase_indent!
        block.call
      ensure
        decrease_indent!
      end
    end

    ##
    # @return [void]
    def increase_indent!
      @indent += 1
    end

    ##
    # @return [void]
    def decrease_indent!
      @indent -= 1
    end
  end # Generator
end # SXP
