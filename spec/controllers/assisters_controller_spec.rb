require 'rails_helper'

describe AssistersController, type: :controller do
  describe '#index' do
    it 'returns a 200 stats' do
      get :index

      expect(response.status).to eq 200
    end
  end
end