# frozen_string_literal: true

module Assembler
  module Errors
    # Base class for all error raised by the Assembler.
    class AssemblerError < StandardError
      # :reek:Attribute (Used simply to store the line number)
      attr_accessor :line_number
    end
  end
end
