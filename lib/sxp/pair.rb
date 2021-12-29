# -*- encoding: utf-8 -*-
module SXP
  ##
  class Pair
    # @return [Object]
    attr_accessor :head

    # @return [Object]
    attr_accessor :tail

    ##
    # @param  [Object] head
    # @param  [Object] tail
    def initialize(head = nil, tail = nil)
      @head, @tail = head, tail
    end

    ##
    # Returns `true` if the head and tail of this pair are both `nil`.
    #
    # @return [Boolean]
    def empty?
      head.nil? && tail.nil?
    end

    ##
    # Returns `true` if the tail of this pair is not `nil` or another pair.
    #
    # @return [Boolean]
    # @see    https:/srfi.schemers.org/srfi-1/srfi-1.html#ImproperLists
    def dotted?
      !proper?
    end

    ##
    # Returns `true` if the tail of this pair is `nil` or another pair.
    #
    # @return [Boolean]
    # @see    https:/srfi.schemers.org/srfi-1/srfi-1.html#ImproperLists
    def proper?
      tail.nil? || tail.is_a?(Pair)
    end

    ##
    # Returns an array representation of this pair.
    #
    # @return [Array]
    def to_a
      [head, tail]
    end

    ##
    # Returns a developer-friendly representation of this pair.
    #
    # @return [String]
    def inspect
      case
        when tail.nil?
          "(#{head.inspect})"
        else
          "(#{head.inspect} . #{tail.inspect})"
      end
    end
  end # Pair
end # SXP
