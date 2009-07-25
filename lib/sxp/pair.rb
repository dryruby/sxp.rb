module SXP
  class Pair
    attr_accessor :head
    attr_accessor :tail

    def initialize(head = nil, tail = nil)
      @head, @tail = head, tail
    end

    def inspect
      case
        when tail.nil?
          "(#{head.inspect})"
        else
          "(#{head.inspect} . #{tail.inspect})"
      end
    end

    def empty?
      head.nil? && tail.nil?
    end

    ##
    # @see http://srfi.schemers.org/srfi-1/srfi-1.html#ImproperLists
    def dotted?
      !proper?
    end

    ##
    # @see http://srfi.schemers.org/srfi-1/srfi-1.html#ImproperLists
    def proper?
      tail.nil? || tail.is_a?(Pair)
    end

    def to_a
      [head, tail]
    end
  end
end
