# frozen_string_literal: true

require_relative '../../refinaments/integer'

RSpec.shared_examples_for 'Integer#two_complement' do
  it 'returns the expected complement for the given number' do
    examples.each do |example|
      expect(example[:number].two_complement)
        .to eq(example[:expectation])
    end
  end
end

RSpec.shared_examples_for 'Integer#to_a' do
  it 'returns the expected array' do
    examples.each do |example|
      expect(example[:number].to_a)
        .to eq(example[:expectation])
    end
  end
end

RSpec.describe Integer do
  describe '#two_complement' do
    context 'with 0' do
      it 'returns 0' do
        expect(0.two_complement).to eq(0)
      end
    end

    context 'with a positive number' do
      let(:number) { rand(1..65_535) }

      it 'returns self' do
        expect(number.two_complement).to eq(number)
      end
    end

    context 'with a negative number longer than 16-bits' do
      let(:number) { rand(-99_000...-32_768) }

      it 'raises a TypeError' do
        expect { number.two_complement }.to raise_error(
          TypeError, 'Integers longer than 16-bits are not supported'
        )
      end
    end

    context 'with 8-bit integers' do
      let(:examples) do
        [
          { number: -1, expectation: 255 },
          { number: -128, expectation: 128 },
          { number: -15, expectation: 241 },
          { number: -64, expectation: 192 }
        ]
      end

      it_behaves_like 'Integer#two_complement'
    end

    context 'with 16-bit integers' do
      let(:examples) do
        [
          { number: -129, expectation: 65_407 },
          { number: -32_768, expectation: 32_768 },
          { number: -16_000, expectation: 49_536 },
          { number: -7_600, expectation: 57_936 },
        ]
      end

      it_behaves_like 'Integer#two_complement'
    end
  end

  describe '#to_a' do
    context 'with 0' do
      it 'returns an array with 0' do
        expect(0.to_a).to eq([0])
      end
    end

    context 'with a 8-bit integer' do
      context 'with a positive integer' do
        let(:number) { rand(1..255) }

        it 'returns the integer inside an array' do
          expect(number.to_a).to eq([number])
        end
      end

      context 'with a negative integer' do
        let(:number) { rand(-128..-1) }

        it "returns the number's two's complement inside an array" do
          expect(number.to_a).to eq([number.two_complement])
        end
      end
    end

    context 'with a 16-bit integer' do
      context 'with a positive integer' do
        let(:examples) do
          [
            {number: 0x4fe9, expectation: [0xe9, 0x4f]},
            {number: 0x39a0, expectation: [0xa0, 0x39]},
            {number: 0x6df0, expectation: [0xf0, 0x6d]},
            {number: 0x95b, expectation: [0x5b, 0x9]}
          ]
        end

        it_behaves_like 'Integer#to_a'
      end

      context 'with a negative integer' do
        let(:examples) do
          [
            {number: -0xcdb, expectation: [0x25, 0xf3]},
            {number: -0x542e, expectation: [0xd2, 0xab]},
            {number: -0x5196, expectation: [0x6a, 0xae]},
            {number: -0x249a, expectation: [0x66, 0xdb]}
          ]
        end

        it_behaves_like 'Integer#to_a'
      end
    end
  end
end
