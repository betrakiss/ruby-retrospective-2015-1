class RationalSequence
  include Enumerable

  def initialize(limit)
    @limit = limit
    @rising, @finished = true, true
    @num, @denom = 1, 1
  end

  def each
    current = Rational(@num, @denom)
    total = [current]

    yield current if @limit != 0

    while total.count < @limit
      current = iteration(total)

      unless total.include? current
        yield current
        total << current
      end
    end
  end

  def iteration(total)
      if @rising and @finished
        @num += 1
        @rising = false
      elsif @finished
        @denom += 1
        @rising = true
      end

      if @finished
        @finished = false
        return Rational(@num, @denom)
      end

      @num, @denom = generate_parts()

      @finished = true if @num == 1 or @denom == 1
      Rational(@num, @denom)
    end

  def generate_parts()
    @rising ? [@num + 1, @denom - 1] : [@num - 1, @denom + 1]
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
  module_function

  def meaningless(n)
    rationals = RationalSequence.new(n).to_a
    primes = rationals.select { |rat| rat.numerator.prime? or rat.denominator.prime? }
    not_primes = rationals - primes

    primes_sum = primes.reduce { |a, b| a * b }
    primes_sum = 1 if not primes_sum

    primes_sum / not_primes.reduce { |a, b| a * b }
  end

  def aimless(n)
    primes = PrimeSequence.new(n).to_a
    primes = primes.each_slice(2).to_a

    primes[-1] << 1 if primes[-1].count == 1
    rationals = primes.map { |prime| Rational(prime[0], prime[1]) }
    rationals.reduce { |a, b| a + b }
  end

  def worthless(n)
    nth_fibonacci = FibonacciSequence.new(n).to_a[-1]
    rationals = RationalSequence.new(n).to_a

    sum = rationals.reduce { |a, b| a + b }
    while sum > nth_fibonacci
      rationals.pop
      sum = rationals.reduce { |a, b| a + b }
    end

    rationals
  end
end
