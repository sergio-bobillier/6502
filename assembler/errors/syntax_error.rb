# frozen_string_literal: true

require_relative 'assembler_error'

module Assembler
  module Errors
    # An error to be raised when the assembler encounters a Syntax Error
    class SyntaxError < ::Assembler::Errors::AssemblerError; end
  end
end
