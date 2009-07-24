module SXP
  class Generator
    def self.string(*sxps)
      require 'stringio' unless defined?(StringIO)
      write(StringIO.new, *sxps).string
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
      @buffer = buffer
    end
  end
end
