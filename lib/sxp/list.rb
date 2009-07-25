require 'sxp/pair'

module SXP
  class List < Pair
    include Enumerable

    def self.[](*elements)
      self.new(elements)
    end

    def initialize(elements = [], &block)
      @pair = nil
      unshift(*elements) unless elements.empty?
      block.call(self) if block_given?
    end

    def inspect
      "(" << map { |value| value.inspect }.join(' ') << ")"
    end

    def head() first end
    def tail() rest end

    def rest
      empty? ? false : @pair.tail
    end

    # Array interface

    def &(other)
      self.class.new(self.to_a & other.to_a)
    end

    def |(other)
      self.class.new(self.to_a | other.to_a)
    end

    def *(times)
      result = (self.to_a * times)
      result.is_a?(Array) ? self.class.new(result) : result
    end

    def +(other)
      self.class.new(self.to_a + other.to_a)
    end

    def -(other)
      self.class.new(self.to_a - other.to_a)
    end

    def <<(object)
      push(object)
      self
    end

    def <=>(other)
      to_a <=> other.to_a
    end

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

    def [](*args)
      result = to_a[*args]
      result.is_a?(Array) ? self.class.new(result) : result # FIXME
    end

    def []=(*args)
      raise NotImplementedError # TODO
    end

    def assoc(object)
      raise NotImplementedError # TODO
    end

    def at(index)
      to_a.at(index)
    end

    def clear
      @pair = nil
      self
    end

    def collect!(&block)
      raise NotImplementedError # TODO
    end

    def compact
      self.class.new(to_a.compact)
    end

    def compact!
      raise NotImplementedError # TODO
    end

    def concat(other)
      raise NotImplementedError # TODO
    end

    def delete(object, &block)
      raise NotImplementedError # TODO
    end

    def delete_at(index)
      raise NotImplementedError # TODO
    end

    def delete_if(&block)
      raise NotImplementedError # TODO
    end

    def each(&block)
      pair = @pair
      while pair != nil
        block.call(pair.head)
        pair = pair.tail
      end
      self
    end

    def each_index(&block)
      index = 0
      each do
        block.call(index)
        index += 1
      end
      self
    end

    def empty?
      @pair.nil?
    end

    def eql?(other)
      case other
        when self then true
        when List
          self.length == other.length && to_a.eql?(other.to_a)
      end
    end

    def fetch(*args, &block)
      to_a.fetch(*args, &block)
    end

    def fill(*args, &block)
      raise NotImplementedError # TODO
    end

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

    def flatten
      raise NotImplementedError # TODO
    end

    def flatten!
      raise NotImplementedError # TODO
    end

    def include?(object)
      to_a.include?(object)
    end

    def index(object)
      to_a.index(object)
    end

    def insert(index, *objects)
      raise NotImplementedError # TODO
    end

    def join(separator = $,)
      to_a.join(separator)
    end

    def last(count = nil)
      case
        when count.nil?
          to_a.last
        else
          to_a.last(count)
      end
    end

    def length
      @length ||= to_a.length
    end

    def map!(&block)
      collect!(&block)
    end

    def nitems
      to_a.nitems
    end

    def pack(template)
      to_a.pack(template)
    end

    def pop
      raise NotImplementedError # TODO
    end

    def push(*objects)
      raise NotImplementedError # TODO
    end

    def rassoc(key)
      raise NotImplementedError # TODO
    end

    def reject!(&block)
      raise NotImplementedError # TODO
    end

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

    def reverse
      self.class.new(to_a.reverse)
    end

    def reverse!
      raise NotImplementedError # TODO
    end

    def reverse_each(&block)
      to_a.reverse_each(&block)
      self
    end

    def rindex(object)
      to_a.rindex(object)
    end

    def shift
      raise NotImplementedError # TODO
    end

    def size
      length
    end

    def slice(*args)
      self[*args]
    end

    def slice!(*args)
      raise NotImplementedError # TODO
    end

    def sort(&block)
      (array = to_a).sort!(&block)
      self.class.new(array)
    end

    def sort!
      raise NotImplementedError # TODO
    end

    def to_list
      self
    end

    def to_pair
      @pair
    end

    def to_s
      join
    end

    def transpose
      self.class.new(to_a.transpose)
    end

    def uniq
      self.class.new(to_a.uniq)
    end

    def uniq!
      raise NotImplementedError # TODO
    end

    def unshift(*objects)
      objects.reverse_each do |object|
        @pair = Pair.new(object, @pair)
      end
      self
    end

    def values_at(*selector)
      self.class.new(to_a.values_at(*selector))
    end
  end
end
