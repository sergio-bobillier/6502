# frozen_string_literal: true

require_relative '../refinaments/integer'
require_relative 'errors/assembler_error'
require_relative 'instructions/instruction'

module Assembler
  # An assembler for the 6502 Assembly Language
  class Assembler
    attr_reader :text, :errors

    # Creates a new instance of the class.
    # @param [String] text The Assembly Language text to assemble.
    def initialize(text)
      @text = text
      @instructions = []
      @errors = []
    end

    # Assembles the given text into machine language instructions.
    # @raise [Assembler::Errors::AssemblerError] If an error is encountered
    #   durig the assemble process.
    def assemble
      text.each_line.with_index do |line, index|
        @line_number = index + 1
        line.chomp!.strip!
        next if line.empty?

        parse(line)
      end

      return unless errors?

      raise_assembler_error
    end

    # @return [Boolean] True if an error occurred during the assemble process,
    #   false otherwise.
    def errors?
      errors.any?
    end

    # @return [Boolean] True if the given text was assembled successfully, false
    #   otherwise.
    def success?
      errors.empty? && instructions.any?
    end

    # Converts each of the (already assembled) instructions into machine code.
    # @return [Array<Integer>] An array of bytes, the machine code for the
    #   assembled instructions.
    # @raise [Assembler::Errors::AssemblerError] If an error ocurred during the
    #   assembly process.
    def binary
      @binary ||= to_binary
    end

    private

    attr_reader :instructions, :line_number

    # Parses the given line, creates an instruction out of it and tries to
    # assemble it. If the instruction is successfully assembled then it is added
    # to the +instructions+ array.
    # @param [String] The line of Assembly Language to parse.
    def parse(line)
      tokens = line.split(/\s+/, 2)
      instruction = ::Assembler::Instructions::Instruction.new(*tokens)
      instruction.assemble

      instructions << instruction
    rescue ::Assembler::Errors::AssemblerError => assembler_error
      assembler_error.line_number = line_number
      @errors << assembler_error
    end

    # @raise [Assembler::Errors::AssemblerError] Is always raised (includes a
    #   message with the number of occurred errors).
    def raise_assembler_error
      raise ::Assembler::Errors::AssemblerError,
            "#{errors.length} error(s) occurred during the assemble process."
    end

    # Converts each of the (already assembled) instructions into machine code.
    # @return [Array<Integer>] An array of bytes, the machine code for the
    #   assembled instructions.
    # @raise [Assembler::Errors::AssemblerError] If an error ocurred during the
    #   assembly process.
    def to_binary
      assemble unless instructions.any?

      # If the assembly process stopped halfway due to an error there may be
      # some instructions in the instructions array but they cannot be converted
      # to machine code, therefore an error is raised.
      raise_assembler_error unless success?

      instructions.each_with_object([]) do |instruction, byte_array|
        byte_array << instruction.opcode
        byte_array.concat(instruction.operand.to_a)
      end
    end
  end
end
