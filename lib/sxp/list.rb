# -*- encoding: utf-8 -*-
require 'sxp/pair'

module SXP
  ##
  # A singly-linked list.
  class List < Pair
    include Enumerable

    ##
    # @param  [Array]  elements
    # @return [Object]
    def self.[](*elements)
      self.new(elements)
    end

    ##
    # @param  [Array]  elements
    # @yield  [list]
    # @yieldparam [List] list
    def initialize(elements = [], &block)
      @pair = nil
      unshift(*elements) unless elements.empty?
      block.call(self) if block_given?
    end

    ##
    # @return [String]
    def inspect
      "(" << map { |value| value.inspect }.join(' ') << ")"
    end

    ##
    # @return [Object]
    def head
      first
    end

    ##
    # @return [Object]
    def tail
      rest
    end

    ##
    # @return [Object]
    def rest
      empty? ? false : @pair.tail
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def &(other)
      self.class.new(self.to_a & other.to_a)
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def |(other)
      self.class.new(self.to_a | other.to_a)
    end

    ##
    # @param  [Object] times
    # @return [Object]
    def *(times)
      result = (self.to_a * times)
      result.is_a?(Array) ? self.class.new(result) : result
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def +(other)
      self.class.new(self.to_a + other.to_a)
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def -(other)
      self.class.new(self.to_a - other.to_a)
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def <<(object)
      push(object)
      self
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def <=>(other)
      to_a <=> other.to_a
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def ==(other)
      case other
        when List
          self.length == other.length && to_a == other.to_a
        when other.respond_to?(:to_list)
          other.to_list == self
        else
          false
      end
    end

    ##
    # @param  [Array]   args
    # @return [Object]
    def [](*args)
      result = to_a[*args]
      result.is_a?(Array) ? self.class.new(result) : result # FIXME
    end

    ##
    # @param  [Array]   args
    # @return [Object]
    def []=(*args)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def assoc(object)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Integer] index
    # @return [Object]
    def at(index)
      to_a.at(index)
    end

    ##
    # @return [Object]
    def clear
      @pair = nil
      self
    end

    ##
    # @return [Object]
    def collect!(&block)
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def compact
      self.class.new(to_a.compact)
    end

    ##
    # @return [Object]
    def compact!
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] other
    # @return [Object]
    def concat(other)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def delete(object, &block)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Integer] index
    # @return [Object]
    def delete_at(index)
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def delete_if(&block)
      raise NotImplementedError # TODO
    end

    ##
    # @return [Enumerator]
    def each(&block)
      pair = @pair
      while pair != nil
        block.call(pair.head)
        pair = pair.tail
      end
      self
    end

    ##
    # @return [Enumerator]
    def each_index(&block)
      index = 0
      each do
        block.call(index)
        index += 1
      end
    end

    ##
    # @return [Boolean]
    def empty?
      @pair.nil?
    end

    ##
    # @param  [Object] other
    # @return [Boolean]
    def eql?(other)
      case other
        when self then true
        when List
          self.length == other.length && to_a.eql?(other.to_a)
      end
    end

    ##
    # @param  [Array]  args
    # @return [Object]
    def fetch(*args, &block)
      to_a.fetch(*args, &block)
    end

    ##
    # @param  [Array]  args
    # @return [Object]
    def fill(*args, &block)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Integer] count
    # @return [Object]
    def first(count = nil)
      case
        when count.nil?
          @pair.head unless empty?
        when count == 1
          empty? ? [] : [first]
        when count > 1
          empty? ? [] : to_a.first(count)
      end
    end

    ##
    # @return [Object]
    def flatten
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def flatten!
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def include?(object)
      to_a.include?(object)
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def index(object)
      to_a.index(object)
    end

    ##
    # @param  [Integer] index
    # @param  [Array]   objects
    # @return [Object]
    def insert(index, *objects)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [String] separator
    # @return [Object]
    def join(separator = $,)
      to_a.join(separator)
    end

    ##
    # @param  [Integer] count
    # @return [Object]
    def last(count = nil)
      case
        when count.nil?
          to_a.last
        else
          to_a.last(count)
      end
    end

    ##
    # @return [Integer]
    def length
      @length ||= to_a.length
    end

    ##
    # @return [Object]
    def map!(&block)
      collect!(&block)
    end

    ##
    # @return [Integer]
    def nitems
      to_a.nitems
    end

    ##
    # @param  [Object] template
    # @return [Object]
    def pack(template)
      to_a.pack(template)
    end

    ##
    # @return [Object]
    def pop
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Array]  objects
    # @return [Object]
    def push(*objects)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] key
    # @return [Object]
    def rassoc(key)
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def reject!(&block)
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Object] other_list
    # @return [Object]
    def replace(other_list)
      case other_list
        when Pair
          @pair = other_list
        when List
          @pair = other_list.to_pair
        when Array
          @pair = nil
          unshift(*other_list)
        else
          # TODO
      end
      self
    end

    ##
    # @return [Object]
    def reverse
      self.class.new(to_a.reverse)
    end

    ##
    # @return [Object]
    def reverse!
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def reverse_each(&block)
      to_a.reverse_each(&block)
      self
    end

    ##
    # @param  [Object] object
    # @return [Object]
    def rindex(object)
      to_a.rindex(object)
    end

    ##
    # @return [Object]
    def shift
      raise NotImplementedError # TODO
    end

    ##
    # @return [Integer]
    def size
      length
    end

    ##
    # @param  [Array]  args
    # @return [Object]
    def slice(*args)
      self[*args]
    end

    ##
    # @param  [Array]  args
    # @return [Object]
    def slice!(*args)
      raise NotImplementedError # TODO
    end

    ##
    # @return [Object]
    def sort(&block)
      (array = to_a).sort!(&block)
      self.class.new(array)
    end

    ##
    # @return [Object]
    def sort!
      raise NotImplementedError # TODO
    end

    ##
    # @return [List]
    def to_list
      self
    end

    ##
    # @return [Pair]
    def to_pair
      @pair
    end

    ##
    # @return [String]
    def to_s
      join
    end

    ##
    # @return [Object]
    def transpose
      self.class.new(to_a.transpose)
    end

    ##
    # @return [Object]
    def uniq
      self.class.new(to_a.uniq)
    end

    ##
    # @return [Object]
    def uniq!
      raise NotImplementedError # TODO
    end

    ##
    # @param  [Array]  objects
    # @return [Object]
    def unshift(*objects)
      objects.reverse_each do |object|
        @pair = Pair.new(object, @pair)
      end
      self
    end

    ##
    # @param  [Array]  selector
    # @return [Object]
    def values_at(*selector)
      self.class.new(to_a.values_at(*selector))
    end
  end # List
end # SXP
