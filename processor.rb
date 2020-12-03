# frozen_string_literal: true

require_relative 'decoder'
require_relative 'memory'
require_relative 'memory_fetcher'

# Models the 6502 Micro Processor's Core
class Processor
  include MemoryFetcher

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

  def initialize(memory:, decoder:)
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

  # Blocks the current Thread until the processor finishes (halts or crash).
  # Mainly needed for testing.
  def wait
    @clock.join
  end

  private

  attr_reader :clock

  def run
    @clock = Thread.new do
      instruction = decoder.decode_at(program_counter)
    end
  end
end
