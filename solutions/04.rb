class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.capitalize rescue rank} of #{suit.capitalize}"
  end

  def ==(other)
    rank == other.rank and suit == other.suit
  end
end

class Deck
  SUITS = [:diamonds, :spades, :clubs, :hearts].freeze
  RANKS = Hash[[2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace].
                map.
                with_index.
                to_a]

  class Hand
    include Enumerable

    attr_reader :cards

    def initialize(cards)
      @cards = cards
    end

    def size
      @cards.size
    end

    def each(&block)
      @cards.each(&block)
    end
  end

  include Enumerable

  def initialize(cards = nil)
    @cards = cards ? cards.dup : generate_all_cards
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort! { |a, b| [b.suit, ranks[b.rank]] <=> [a.suit, ranks[a.rank]] }
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  def deal
    hand_class.new(@cards.shift(hand_size))
  end

  def each(&block)
    @cards.each(&block)
  end

  def generate_all_cards
    ranks.keys.product(SUITS).map { |r, s| Card.new(r, s) }
  end
end

class WarDeck < Deck
  HAND_SIZE = 26
  TOTAL_CARDS = 52

  class Hand < Deck::Hand
    ALLOW_FACE_UP_COUNT = 3

    def play_card
      @cards.delete(@cards.sample)
    end

    def allow_face_up?
      size <= ALLOW_FACE_UP_COUNT
    end
  end

  def hand_size
    HAND_SIZE
  end

  def hand_class
    Hand
  end

  def ranks
    RANKS
  end
end



class BeloteDeck < Deck
  RANKS = Hash[[7, 8, 9, :jack, :queen, :king, 10, :ace].map.with_index.to_a]
  HAND_SIZE = 8
  TOTAL_CARDS = 32

  class Hand < Deck::Hand
    CARRE_COUNT = 4

    def highest_of_suit(suit)
      select { |c| c.suit == suit }.
        sort { |a, b| [b.suit, RANKS[b.rank]] <=> [a.suit, RANKS[a.rank]] }.
        first
    end

    def belote?
      Deck::SUITS.any? do |suit|
        include?(Card.new(:king, suit)) and
          include?(Card.new(:queen, suit))
      end
    end

    def tierce?
      consecutive_cards?(3)
    end

    def quarte?
      consecutive_cards?(4)
    end

    def quint?
      consecutive_cards?(5)
    end

    def carre_of_jacks?
      carre?(:jack)
    end

    def carre_of_nines?
      carre?(9)
    end

    def carre_of_aces?
      carre?(:ace)
    end

    private
    def consecutive_cards?(amount)
      grouped = @cards.sort! { |a, b| RANKS[a.rank] <=> RANKS[b.rank] }.
                       group_by { |card| card.suit }.values

      grouped.any? do |suited|
        next if suited.size < amount

        suited.each_cons(amount).any? do |con|
          are_following_numbers?(con)
        end
      end
    end

    def are_following_numbers?(numbers)
      numbers.each_cons(2).all? do |a, b|
        RANKS[b.rank] - RANKS[a.rank] == 1
      end
    end

    def carre?(rank)
      select { |card| card.rank == rank }.size == CARRE_COUNT
    end
  end

  def hand_size
    HAND_SIZE
  end

  def hand_class
    Hand
  end

  def ranks
    RANKS
  end
end

class SixtySixDeck < Deck
  RANKS = Hash[[9, :jack, :queen, :king, 10, :ace].map.with_index.to_a]
  HAND_SIZE = 6
  TOTAL_CARDS = 24

  class Hand < Deck::Hand
    def twenty?(trump_suit)
      kings_and_queens?(Deck::SUITS - [trump_suit])
    end

    def forty?(trump_suit)
      kings_and_queens?([trump_suit])
    end

    private
    def kings_and_queens?(allowed_suits)
      allowed_suits.any? do |suit|
        include?(Card.new(:king, suit)) and
          include?(Card.new(:queen, suit))
      end
    end
  end

  def hand_size
    HAND_SIZE
  end

  def hand_class
    Hand
  end

  def ranks
    RANKS
  end
end
