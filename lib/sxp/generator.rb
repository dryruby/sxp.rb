module SXP
  class Generator
    def self.string(*sxps)
      require 'stringio' unless defined?(StringIO)
      write(StringIO.new, *sxps).instance_variable_get('@buffer').string
    end

    def self.print(*sxps)
      write($stdout, *sxps)
    end

    def self.write(out, *sxps)
      generator = self.new(out)
      sxps.each do |sxp|
        generator.send((op = sxp.shift).to_sym, *sxp)
      end
      generator
    end

    def initialize(buffer)
      @output = [@buffer = buffer]
      @indent = 0
    end

    protected

      def emit(text, options = {})
        if out = @output.last
          out.print(' ' * (indent * 2)) if options[:indent]
          out.print(text)
        end
      end

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

      def indented(&block)
        begin
          increase_indent!
          block.call
        ensure
          decrease_indent!
        end
      end

      def increase_indent!()
        @indent += 1
      end

      def decrease_indent!()
        @indent -= 1
      end
  end
end
