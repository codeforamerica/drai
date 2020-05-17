require 'rails_helper'

describe Seeder do
  describe '.seed' do
    it "can be run multiple times and does not raise any errors" do
      expect { Seeder.seed }.not_to raise_error
      expect { Seeder.seed }.not_to raise_error
    end
  end
end
