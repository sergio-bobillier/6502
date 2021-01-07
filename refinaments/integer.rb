# frozen_string_literal: true

# A refinament of Ruby's Integer class.
class Integer
  # Converts the receiver into an array of bytes with Little Endian encoding.
  # @return [Array<Integer>] A byte array created from the receiver's value
  # :reek:FeatureEnvy
  def to_a
    return [0] if zero?

    value = two_complement
    array = []

    while value.positive?
      array << (value & 0xff)
      value = value >> 8
    end

    array
  end

  # Returns the receiver's two's complement.
  # @return [Integer] The receiver's two's complement when it is negative or
  #   self if it is positive or zero.
  # @raise [TyoeError] If the integer is longer than 16 bits.
  def two_complement
    return self unless negative?
    raise TypeError, 'Integers longer than 16-bits are not supported' if bit_length >= 16

    value = bit_length < 8 ? 0x100 : 0x10000
    self + value
  end
end
