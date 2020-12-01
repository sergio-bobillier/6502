# frozen_string_literal: true

require_relative 'decoder'
require_relative 'memory'
require_relative 'refinaments/array'

# Models the 6502 Micro Processor's Core
class Processor
  RESET_VECTOR = 0xFFFC

  DEFAULT_STATUS = 0b00100000
  #                  || |||||
  #                  || ||||+- Carry
  #                  || |||+-- Zero
  #                  || ||+--- IRQ Disable
  #                  || |+---- Decimal Mode
  #                  || +----- Break Command
  #                  |+------- Overflow
  #                  +-------- Negative

  STACK_START = 0x01FF

  attr_reader :memory, :decoder, :accumulator, :x_index, :y_index,
              :program_counter, :status, :stack_pointer

  def initialize(memory: Memory.new, decoder: Decoder.new)
    @memory = memory
    @decoder = decoder
    reset
  end

  def reset
    clock&.kill

    @accumulator = 0
    @x_index = 0
    @y_index = 0
    @program_counter = memory_fetch(RESET_VECTOR, 2)
    @status = DEFAULT_STATUS
    @stack_pointer = STACK_START
  end

  def reset!
    reset
    run
  end

  private

  attr_reader :clock

  def run
    @clock = Thread.new do
    end
  end

  # Reads data from the given memory address and returns it as an integer.
  # If more than one byte of data is read (`length` is greater than 1) the
  # value will be decoded together as a single integer.
  # @param [Integer] address The address to read from.
  # @param [Integer] integer The length of the data to be read (in bytes)
  # @return [Integer] The data at the given address.
  # @raise [Error::MemoryReadError] If the given address(es) cannot be read.
  def memory_fetch(address, length)
    return memory.read(address) if length == 1

    data = []
    length.times do |offset|
      data << memory.read(address + offset)
    end

    data.to_i
  end
end
