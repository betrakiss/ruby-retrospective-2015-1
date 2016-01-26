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
