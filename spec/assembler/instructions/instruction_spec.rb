# frozen_string_literal: true

require_relative '../../../assembler/instructions/instruction'

RSpec.shared_examples_for 'Assembler::Instructions::Instruction#assemble' do
  context 'with an unknown mnemonic' do
    let(:mnemonic) { 'LDB' }

    it 'raises an UnknownMnemonicError' do
      expect { method_call }.to raise_error(
        Assembler::Errors::UnknownMnemonicError,
        'Unknown or misspelled mnemonic: LDB'
      )
    end
  end

  context 'with an uncompatible addressing mode' do
    let(:argument) { nil }

    it 'raises an Assembler::Error::SyntaxError' do
      expect { method_call }.to raise_error(
        Assembler::Errors::SyntaxError,
        'Invalid addresing mode: A, i for the LDA mnemonic'
      )
    end
  end

  describe 'operand parsing' do
    context 'with a binary operand' do
      let(:argument) { '%1110011' }

      it 'correctly parser the operand' do
        method_call
        expect(instruction.operand).to eq(0b1110011)
      end
    end

    context 'with a hexadecimal operand' do
      let(:argument) { '$af27' }

      it 'correctly parser the operand' do
        method_call
        expect(instruction.operand).to eq(0xaf27)
      end
    end

    context 'with a decimal literal' do
      let(:argument) { '#32' }

      it 'correctly parser the operand' do
        method_call
        expect(instruction.operand).to eq(32)
      end
    end
  end

  context 'with a decimal literal that is too long' do
    let(:argument) { '#999' }

    it 'raises a Assembler::Errors::OverflowError' do
      expect { method_call }.to raise_error(
        Assembler::Errors::OverflowError,
        '10-bit literal 999 is too long'
      )
    end
  end

  context 'with a hexadecimal literal that is too long' do
    let(:argument) { '#$f2f7' }

    it 'raises a Assembler::Errors::OverflowError' do
      expect { method_call }.to raise_error(
        Assembler::Errors::OverflowError,
        '16-bit literal $f2f7 is too long'
      )
    end
  end

  it 'correctly sets the opcode' do
    method_call
    expect(instruction.opcode).to eq(0xA9)
  end

  it 'correctly sets the opperand' do
    method_call
    expect(instruction.operand).to eq(0x22)
  end

  context 'with a valid mnemonic and argument' do
    it 'does mot raise an error' do
      expect { method_call }.not_to raise_error
    end
  end
end

RSpec.describe Assembler::Instructions::Instruction do
  subject(:instruction) { described_class.new(mnemonic, argument) }

  let(:mnemonic) { 'LDA' }
  let(:argument) { '#$22' }

  describe '#initialize' do
    context 'when the given mnemonic is in lowercase' do
      let(:mnemonic) { 'ldx' }

      it 'converts it to uppercase' do
        expect(instruction.mnemonic).to eq('LDX')
      end
    end
  end

  describe '#addressing_modes' do
    let(:method_call) { instruction.addressing_modes }

    context 'with no argument' do
      let(:argument) { nil }

      it 'returns an array with the addressing modes Accumulator and Indirect' do
        expect(method_call).to eq(%w[A i])
      end
    end

    context 'with a malformed argument' do
      let(:argument) { ['-10', '$1z2', '%1111,t'].sample }

      it 'raises an Assembler::Errors::SyntaxError' do
        expect { method_call }.to raise_error(
          Assembler::Errors::SyntaxError,
          "Unknown, incompatible or malformed argument: #{argument}"
        )
      end
    end

    context 'with an immediate number literal' do
      it 'returns an array with the addressing mode Immediate' do
        expect(method_call).to eq(%w[#])
      end
    end

    context 'with an 8-bit binary literal' do
      let(:argument) { '%01100111' }

      it 'returns an array with the addressing modes Zero Page and Relative' do
        expect(method_call).to eq(%w[zp r])
      end
    end

    context 'with a 16-bit hexadecimal literal' do
      let(:argument) { '$32f' }

      it 'returns an array with the addressing mode Absolute' do
        expect(method_call).to eq(%w[a])
      end
    end

    context 'with a decimal literal with index' do
      let(:argument) { '32200,x' }

      it 'returns an array with the addressing mode Absolute Indexed with X' do
        expect(method_call).to eq(%w[a,x])
      end
    end
  end

  describe '#assemble' do
    subject(:method_call) { instruction.assemble }

    it_behaves_like 'Assembler::Instructions::Instruction#assemble'

    it 'returns nil' do
      # NOTE: This is important because of the way opcode, operand and size are
      # implemented, assemble MUST return nil.
      expect(method_call).to be_nil
    end
  end

  describe '#opcode' do
    subject(:method_call) { instruction.opcode }

    it_behaves_like 'Assembler::Instructions::Instruction#assemble'

    it "returns the instruction's opcode" do
      expect(method_call).to eq(0xA9)
    end
  end

  describe '#operand' do
    subject(:method_call) { instruction.operand }

    it_behaves_like 'Assembler::Instructions::Instruction#assemble'

    it "returns the instruction's operand" do
      expect(method_call).to eq(0x22)
    end
  end

  describe '#size' do
    subject(:method_call) { instruction.size }

    it_behaves_like 'Assembler::Instructions::Instruction#assemble'

    context 'with a 1-byte instruction' do
      let(:mnemonic) { 'INX' }
      let(:argument) { nil }

      it 'returns 1' do
        skip('The mnemonic cannot be assembled yet')
        expect(method_call).to eq(1)
      end
    end

    context 'with a 2-byte instruction' do
      it 'returns 2' do
        expect(method_call).to eq(2)
      end
    end

    context 'with a 3-byte instruction' do
      let(:argument) { '$3f02' }

      it 'returns 3' do
        expect(method_call).to eq(3)
      end
    end
  end
end
