# frozen_string_literal: true

require_relative 'decoder'
require_relative 'memory'

class Processor
  RESET_VECTOR = 0xFFFC
  DEFAULT_STATUS = 0x20
  STACK_START = 0x01FF

  attr_reader :memory, :decoder, :accumulator, :index_x, :index_y,
              :program_counter, :status, :stack_pointer

  def initialize(memory: Memory.new, decoder: Decoder.new)
    @memory = memory
    @decoder = decoder
    reset
  end

  def reset
    clock&.kill

    @accumulator = 0
    @index_x = 0
    @index_y = 0
    @program_counter = RESET_VECTOR
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
end
