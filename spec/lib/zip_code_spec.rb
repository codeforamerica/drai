require 'rails_helper'

describe ZipCode do
  describe '.from_county' do
    it 'returns all zip codes in a county' do
      zips = ZipCode.from_county('San Francisco')
      expect(zips).to include '94108'
      expect(zips.size).to be > 20
    end
  end

  describe '#counties' do
    let(:result) { described_class.new(input).counties }

    context 'given a zip code with one county' do
      let(:input) { "94606" }

      it 'returns an array of length 1 with the county name' do
        expect(result).to eq(["Alameda"])
      end
    end

    context 'given a zip code with multiple counties' do
      let(:input) { "94303" }

      it 'returns an array of length 2 with both names' do
        expect(result.sort).to eq(["San Mateo", "Santa Clara"])
      end
    end

    context 'given integer input' do
      let(:input) { 94606 }

      it 'returns the same result as if it were a string' do
        expect(result).to eq(["Alameda"])
      end
    end

    context 'given an invalid zip' do
      let(:input) { '01983' }

      it 'returns an empty array' do
        expect(result).to eq []
      end
    end

    context 'given zip code 94515' do
      let(:input) { '94515' }

      it 'returns the correct counties, Sonoma and Napa' do
        expect(result).to eq ["Napa", "Sonoma"]
      end
    end

    describe 'manually overriden corrections' do
      context '95563' do
        let(:input) { '95563' }

        specify { expect(result).to eq ['Trinity'] }
      end
    end
  end
end
