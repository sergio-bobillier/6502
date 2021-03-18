# frozen_string_literal: true

require_relative '../../../assembler/assembler'

RSpec.describe Assembler::Assembler do
  subject(:assembler) { described_class.new(text) }

  let(:text) do
    <<~ASM
      LDA $3F00
      LDA $4000,X
      LDA $8000,Y
      LDA \#42
      LDA $02
      LDA ($02,X)
      LDA $99,X
      LDA ($33),Y
    ASM
  end

  describe '#assemble' do
    subject(:method_call) { assembler.assemble }

    context 'when there is an assembler error' do
      let(:text) do
        <<~ASM
          LDA \#$04
          ADY $16
          LDA \#-32
        ASM
      end

      it 'raises a Assembler::Errors::AssemblerError' do
        expect { method_call }
          .to raise_error(
            ::Assembler::Errors::AssemblerError,
            '2 error(s) occurred during the assemble process.'
          )
      end

      it 'adds the first error to the errors array' do
        expect { method_call }
          .to raise_error(::Assembler::Errors::AssemblerError)

        expect(assembler.errors.first.message)
          .to eq('Unknown or misspelled mnemonic: ADY')
      end

      it 'adds the second error to the errors array' do
        expect { method_call }
          .to raise_error(::Assembler::Errors::AssemblerError)

        expect(assembler.errors.last.message)
          .to eq('Unknown, incompatible or malformed argument: #-32')
      end
    end

    it 'does not raise any errors' do
      expect { method_call }.not_to raise_error
    end
  end

  describe '#binary' do
    let(:expected_array) do
      [
        0xAD, 0x00, 0x3F, # LDA $3F00
        0xBD, 0x00, 0x40, # LDA $4000,X
        0xB9, 0x00, 0x80, # LDA $8000,Y
        0xA9, 0x2A,       # LDA #42
        0xA5, 0x02,       # LDA $02
        0xA1, 0x02,       # LDA ($02,X)
        0xB5, 0x99,       # LDA $99,X
        0xB1, 0x33        # LDA ($33),Y
      ]
    end

    it 'returns the expected binary array' do
      expect(assembler.binary).to eq(expected_array)
    end
  end
end
