# frozen_string_literal: true

require_relative 'assembler_error'

module Assembler
  module Errors
    # An error to be raised when the Assembler finds an unknown mnemonic.
    class UnknownMnemonicError < ::Assembler::Errors::AssemblerError
      # Creates a new instance of the class.
      # @param [String] mnemonic The mnemonic that caused the error to be raised.
      def initialize(mnemonic)
        super("Unknown or misspelled mnemonic: #{mnemonic}")
      end
    end
  end
end
