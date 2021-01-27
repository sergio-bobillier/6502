# frozen_string_literal: true

require_relative '../../../refinaments/integer'
require_relative '../../../refinaments/array'

RSpec.describe Array do
  context '#to_i -> #to_a' do
    context 'with a single byte array' do
      subject(:array) { [rand(256)] }

      it 'returns the expected array' do
        expect(array.to_i.to_a).to eq(array)
      end
    end

    context 'with a two bytes array' do
      subject(:array) { [rand(256), rand(256)] }

      it 'returns the expected array' do
        expect(array.to_i.to_a).to eq(array)
      end
    end

    context 'with a longer array' do
      subject(:array) do
        array = []
        rand(3..8).times { array << rand(256) }
        array
      end

      it 'returns the expected array' do
        expect(array.to_i.to_a).to eq(array)
      end
    end
  end
end
