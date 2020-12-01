# frozen_string_literal: true

require 'forwardable'

require_relative 'errors/memory_read_error'

class Memory
  extend Forwardable

  DEFAULT_TOP_ADDRESS = 0xFFFF

  attr_reader :address_range

  def_delegator :@memory, :[]=, :write
  def_delegator :@memory, :size

  def initialize(top_address = DEFAULT_TOP_ADDRESS)
    @memory = Array.new(top_address + 1, 0)
    @address_range = (0..top_address)
  end

  # Reads the byte at the given address. If the address is out of the mapped
  # memory space an error is raised.
  # @param [Integer] address The address to read from.
  # @return [Integer] The value at the specified address.
  # @raise [Errors::MemoryReadError] If the specified address is outside of the
  #   memory space.
  def read(address)
    raise Errors::MemoryReadError, address unless address_range.include?(address)

    @memory[address]
  end
end
