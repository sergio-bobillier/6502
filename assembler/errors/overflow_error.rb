# frozen_string_literal: true

require_relative 'assembler_error'

module Assembler
  module Errors
    # An error to be raised when an attempt is made to use a 16-bit leteral
    # where only a 8-bit literal can be taken
    class OverflowError < Assembler::Errors::AssemblerError; end
  end
end
