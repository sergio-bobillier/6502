# frozen_string_literal: true

require_relative '../errors/syntax_error'
require_relative '../errors/overflow_error'
require_relative '../errors/unknown_mnemonic_error'
require_relative 'mnemonics'
require_relative 'addressing_modes'

module Assembler
  module Instructions
    # Base class for all instruction classes
    class Instruction
      include Assembler::Instructions::Mnemonics
      include Assembler::Instructions::AddressingModes

      OPCODES_MAP = {
        LDA => [
          { opcode: 0xAD, addressing_mode: ABSOLUTE, size: 16 },
          { opcode: 0xBD, addressing_mode: ABSOLUTE_X, size: 16 },
          { opcode: 0xB9, addressing_mode: ABSOLUTE_Y, size: 16 },
          { opcode: 0xA9, addressing_mode: IMMEDIATE, size: 8 },
          { opcode: 0xA5, addressing_mode: ZERO_PAGE, size: 8 },
          { opcode: 0xA1, addressing_mode: ZERO_PAGE_INDIRECT_X, size: 8 },
          { opcode: 0xB5, addressing_mode: ZERO_PAGE_X, size: 8 },
          { opcode: 0xB1, addressing_mode: ZERO_PAGE_INDIRECT_Y, size: 8 }
        ]
      }.freeze

      attr_reader :mnemonic, :argument

      # Creates a new instruction from the given arguments, either `opcode` and
      # `operand` or `mnemonic` and `argument` can be given.
      # @param [Sting] mnemonic The Instruction's mnemonic.
      # @param [String] argument Instruction's argument (may be nil for implied
      #   addressing modes)
      def initialize(mnemonic, argument)
        @mnemonic = mnemonic.upcase
        @argument = argument
      end

      # @return [Integer] The instruction's opcode
      def opcode
        @opcode || assemble || @opcode
      end

      # @return [Integer] The instruction's operand
      def operand
        @operand || assemble || @operand
      end

      # @return [Integer] The size of the instruction in bytes:
      #   1 byte for the opcode + the size of the operand
      def size
        @size || assemble || (1 + (operand.bit_length / 8.0).ceil)
      end

      # @return [Array<String>] The array of addressing modes deducted from the
      #   Instruction's argument (may be a single element array)
      # @raise [Assembler::Errors::SyntaxError] If the Instruction's argument
      #   doesn't match any if the known expressions for valid addressing modes.
      def addressing_modes
        @addressing_modes ||= derive_addressing_mode
      end

      # Assembles the instruction: Convers the given mnemonic and argument into
      # the corresponding machine-language opcode and operand.
      # @return [nil] Always returns nil.
      def assemble
        @opcode = opcode_data[:opcode]
        @operand = parse_operand

        operand_length = operand.bit_length
        return if operand_length <= opcode_data[:size]

        raise Assembler::Errors::OverflowError,
              "#{operand_length}-bit literal #{operand_literal} is too long"
      end

      private

      attr_reader :operand_literal

      # Returns the possilble opcodes and compatilble addressing modes for the
      # given mnemonic.
      # @param [String] The mnemonic
      # @return [Arrar] The possile opcodes and addressing modes.
      # @raise [Assembler::Errors::UnknownMnemonicError] If the given mnemonic
      #   cannot be found.
      def opcodes_by_mnemonic(mnemonic)
        OPCODES_MAP[mnemonic] || raise(
          Assembler::Errors::UnknownMnemonicError, mnemonic
        )
      end

      # Derives the addressing mode from the instruction's argument
      # @return [Array<String>] The addressing modes (in most cases only one)
      #   derived from the instruction's argument.
      # @raise [Assembler::Errors::SyntaxError] If the Instruction's argument
      #   doesn't match any if the known expressions for valid addressing modes.
      def derive_addressing_mode
        return [ACCUMULATOR, IMPLIED] unless argument

        ADDRESSING_MODES_MAP.each do |reg_ex, addressing_mode|
          match = reg_ex.match(argument)
          next unless match

          @operand_literal = match[1]
          return Array(addressing_mode)
        end

        raise Assembler::Errors::SyntaxError,
              "Unknown, incompatible or malformed argument: #{argument}"
      end

      # Returns a Hash with the Opcode Data for the Instruction's Mnemonic and
      # Argument.
      # @return [Hash] A Hash with the Opcode Data
      # @raise [Assembler::Errors::SyntaxError] If the Instruction's argument
      #   doesn't match any if the known expressions for valid addressing modes.
      # @raise [Assembler::Errors::SyntaxError] If the addressing mode derived
      #   from the Instruction's Argument is not a valid addressing mode for the
      #   Instruction's mnemonic.
      def opcode_data
        @opcode_data ||= opcodes_by_mnemonic(mnemonic).find do |opcode_data|
          addressing_modes.include?(opcode_data[:addressing_mode])
        end || raise(
          Assembler::Errors::SyntaxError,
          "Invalid addresing mode: #{addressing_modes.join(', ')} for the #{mnemonic} mnemonic"
        )
      end

      # Parses the operand with the appropriate base.
      # @return [Integer] The result of parsing the operand literal.
      def parse_operand
        case operand_literal[0]
        when '%'
          base = 2
          offset = 1
        when '$'
          base = 16
          offset = 1
        else
          base = 10
          offset = 0
        end

        operand_literal[offset..].to_i(base)
      end
    end
  end
end
