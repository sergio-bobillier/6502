# frozen_string_literal: true

module Errors
  # An error to be raised when a memory read error ocurrs. (For example when
  # data is read from a memory address that doesn't exist)
  class MemoryReadError < RuntimeError
    def initialize(addr_or_message)
      return super(addr_or_message) if addr_or_message.is_a?(String)

      super("Memory read error when trying to read address: #{addr_or_message}")
    end
  end
end
