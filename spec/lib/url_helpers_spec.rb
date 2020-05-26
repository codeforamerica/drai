require 'rails_helper'

RSpec.describe UrlHelpers do
  it 'forwards methods to Rails Routes' do
    expect(described_class.root_path).to eq '/'
  end

  it 'merges in hostname' do
    allow(Rails.configuration.action_mailer).to receive(:default_url_options).and_return(host: 'something.com')
    expect(described_class.root_url).to eq 'http://something.com/'
  end

  describe 'inclusion in another class' do
    let(:example_class) do
      Class.new do
        include UrlHelpers
      end
    end

    it 'can be called directly from within the class' do
      example = example_class.new
      expect(example.root_path).to eq '/'
    end
  end
end
