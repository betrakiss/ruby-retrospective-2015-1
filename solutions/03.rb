class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each(&block)
    enum_for(:all_rationals).
      lazy.
      select { |n, d| n.gcd(d) == 1}.
      map { |n, d| Rational(n, d) }.
      take(@limit).
      each(&block)
  end

  private
  def all_rationals
    numerator = 1
    denominator = 1

    loop do
      yield [numerator, denominator]

      numerator += 1

      while numerator > 1
        yield [numerator, denominator]
        numerator -= 1
        denominator += 1
      end

      yield [numerator, denominator]

      denominator += 1

      while denominator > 1
        yield [numerator, denominator]
        denominator -= 1
        numerator += 1
      end
    end
  end
end

class Integer
  def prime?
    return true if self == 2
    return false if self % 2 == 0 or self < 2

    (3..self ** 0.5).step(2).all? { |n| self % n != 0 }
  end
end

class PrimeSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
  end

  def each(&block)
    enum_for(:all_primes).
      lazy.
      take(@limit).
      each(&block)
  end

  private
  def all_primes
    current = 2

    loop do
      yield current if current.prime?
      current += 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def initialize(limit, first: 1, second: 1)
    @limit = limit
    @first = first
    @second = second
  end

  def each(&block)
    enum_for(:all_fibonacci).
      lazy.
      take(@limit).
      each(&block)
  end

  private
  def all_fibonacci
    current, previous = @second, @first

    yield previous
    loop do
      yield current
      current, previous = current + previous, current
    end
  end
end

module DrunkenMathematician
  extend self

  def meaningless(n)
    primes, not_primes = RationalSequence.new(n).
      partition { |r| r.numerator.prime? or r.denominator.prime? }

    primes.reduce(1, :*) / not_primes.reduce(1, :*)
  end

  def aimless(n)
    PrimeSequence.new(n).
      each_slice(2).
      map { |a, b| Rational(a, b || 1) }.
      reduce(:+)
  end

  def worthless(n)
    nth_fibonacci = FibonacciSequence.new(n).to_a.last

    sum = 0
    RationalSequence.new(n).take_while do |n|
      sum += n
      sum <= nth_fibonacci
    end
  end
end
