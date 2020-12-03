# frozen_string_literal: true

require_relative 'refinaments/array'

module MemoryFetcher
  private

  # Reads data from the given memory address and returns it as an integer.
  # If more than one byte of data is read (`length` is greater than 1) the
  # value will be decoded together as a single integer.
  # @param [Integer] address The address to read from.
  # @param [Integer] integer The length of the data to be read (in bytes)
  # @return [Integer] The data at the given address.
  # @raise [Error::MemoryReadError] If the given address(es) cannot be read.
  def memory_fetch(address, length = 1)
    return memory.read(address) if length == 1

    data = []
    length.times do |offset|
      data << memory.read(address + offset)
    end

    data.to_i
  end
end
