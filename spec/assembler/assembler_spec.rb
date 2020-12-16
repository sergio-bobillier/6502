# frozen_string_literal: true

require_relative '../../assembler/assembler'

RSpec.shared_context 'with errors on Assembler::Assembler#assemble' do
  let(:errors_in) do
    [].tap do |array|
      4.times { array << rand(1..4) }
    end.uniq
  end

  let(:expected_error) do
    [
      Assembler::Errors::AssemblerError,
      "#{errors_in.length} error(s) occurred during the assemble process."
    ]
  end

  before do
    index = 0

    allow(mocked_instruction).to receive(:assemble) do
      index += 1

      if errors_in.include?(index)
        raise Assembler::Errors::AssemblerError,
              'Assembler error'
      end
    end
  end
end

RSpec.shared_examples_for 'Assembler::Assembler#assemble' do
  it 'creates a instruction for the first line' do
    expect(Assembler::Instructions::Instruction)
      .to receive(:new).with('LDA', '#$15')

    method_call
  end

  it 'creates a instruction for the second line' do
    expect(Assembler::Instructions::Instruction)
      .to receive(:new).with('LDX', '$D010')

    method_call
  end

  it 'creates a instruction for the third line' do
    expect(Assembler::Instructions::Instruction)
      .to receive(:new).with('JMP', '$5F03')

    method_call
  end

  it 'creates a instruction for the fourth line' do
    expect(Assembler::Instructions::Instruction)
      .to receive(:new).with('ADC', '#$16')

    method_call
  end

  context 'when no errors occur' do
    it 'sets success? to true' do
      method_call
      expect(assembler.success?).to eq(true)
    end

    it 'sets errors? to false' do
      method_call
      expect(assembler.errors?).to eq(false)
    end
  end

  context 'when an error occurs' do
    include_context 'with errors on Assembler::Assembler#assemble'

    it 'raises a Assembler::Errors::AssemblerError' do
      expect { method_call }.to raise_error(*expected_error)
    end

    it 'adds the occurred erros to the errors array' do
      expect { method_call }
        .to raise_error(*expected_error)
        .and change { assembler.errors.length }.to(errors_in.length)
    end

    it 'does not change success?' do
      expect { method_call }
        .to raise_error(*expected_error)
        .and avoid_changing(assembler, :success?)
    end

    it 'changes errors? to true' do
      expect { method_call }
        .to raise_error(*expected_error)
        .and change(assembler, :errors?).to(true)
    end
  end
end

RSpec.describe Assembler::Assembler do
  subject(:assembler) { described_class.new(text) }

  let(:text) do
    <<~ASM
      LDA \#$15
      LDX $D010
      JMP $5F03
      ADC \#$16
    ASM
  end

  let(:mocked_instruction) do
    instance_double(
      Assembler::Instructions::Instruction,
      assemble: true
    )
  end

  before do
    allow(Assembler::Instructions::Instruction)
      .to receive(:new).and_return(mocked_instruction)
  end

  describe '#assemble' do
    subject(:method_call) { assembler.assemble }

    it_behaves_like 'Assembler::Assembler#assemble'
  end

  describe '#errors?' do
    subject(:method_call) { assembler.errors? }

    context "when #assemble hasn't been called" do
      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context 'when #assemble has been called' do
      context 'when there are assembler errors' do
        include_context 'with errors on Assembler::Assembler#assemble'

        before do
          # rubocop:disable Style/RescueModifier
          assembler.assemble rescue nil
          # rubocop:enable Style/RescueModifier
        end

        it 'returns true' do
          expect(method_call).to eq(true)
        end
      end

      context 'when there are no assembler errors' do
        before { assembler.assemble }

        it 'returns false' do
          expect(method_call).to eq(false)
        end
      end
    end
  end

  describe '#success?' do
    subject(:method_call) { assembler.success? }

    context "when #assemble hasn't been called" do
      it 'returns false' do
        expect(method_call).to eq(false)
      end
    end

    context 'when #assemble has been called' do
      context 'when there are assembler errors' do
        include_context 'with errors on Assembler::Assembler#assemble'

        before do
          # rubocop:disable Style/RescueModifier
          assembler.assemble rescue nil
          # rubocop:enable Style/RescueModifier
        end

        it 'returns false' do
          expect(method_call).to eq(false)
        end
      end

      context 'when there are no assembler errors' do
        before { assembler.assemble }

        it 'returns true' do
          expect(method_call).to eq(true)
        end
      end
    end
  end

  describe '#binary' do
    subject(:method_call) { assembler.binary }

    let(:binary) do
      [
        0xA9, 0x15,   # LDA #$15
        0xAE, 0xD010, # LDX $D010
        0x4C, 0x5F03, # JMP $5F03
        0x69, 0x16    # ADC #$16
      ]
    end

    let(:expected_result) do
      [0xA9, 0x15, 0xAE, 0x10, 0xD0, 0x4C, 0x03, 0x5F, 0x69, 0x16]
    end

    before do
      allow(mocked_instruction).to receive(:opcode) do
        binary.shift
      end

      allow(mocked_instruction).to receive(:operand) do
        binary.shift
      end
    end

    it_behaves_like 'Assembler::Assembler#assemble'

    context 'when #assemble has been called' do
      context 'when there are assembler errors' do
        include_context 'with errors on Assembler::Assembler#assemble'

        before do
          # rubocop:disable Style/RescueModifier
          assembler.assemble rescue nil
          # rubocop:enable Style/RescueModifier
        end

        it 'raises a Assembler::Errors::AssemblerError' do
          expect { method_call }.to raise_error(*expected_error)
        end
      end
    end

    it 'returns the expected array of bytes' do
      expect(method_call).to eq(expected_result)
    end
  end
end
