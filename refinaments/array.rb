# frozen_string_literal: true

# Refinament for Ruby's Array class
class Array
  # :reek:FeatureEnvy
  # Returns the integer represented by the receiver (decoded as a Byte array
  # with Little Endianness)
  # @return [Integer] The resulting integer value
  # @raise [TypeError] If one of the values in the array is outsie of the valid
  #   range for bytes (0..255)
  def to_i
    reverse.inject(0) do |integer, byte|
      raise TypeError, "Value out of bounds: #{byte.inspect}" unless (0..255).include?(byte)

      integer = integer << 8
      integer | byte
    end
  end
end
