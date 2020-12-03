# frozen_string_literal: true

require_relative 'memory_fetcher'

# Models the 6502 instruction decoder
class Decoder
  include MemoryFetcher

  attr_reader :memory

  def initialize(memory:)
    @memory = memory
  end

  def decode_at(address)
    opcode = memory_fetch(address, 1)
  end
end
