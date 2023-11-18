# frozen_string_literal: true

require_relative '../lib/arscope'

describe Farm do
  before do
    # Nasty kludge. You can do better than this.
    require_relative '../lib/seed'
  end

  let(:farm) { described_class.new }

  it 'creates a valid farm' do
    expect(farm).to be_valid
  end

  it 'finds a Funny farm' do
    expect(described_class.where(name: 'Funny').first).to be_valid
  end

  it 'Funny Farm finds four animals' do
    funny_farm = described_class.where(name: 'Funny').first
    expect(funny_farm.animals.size).to eq 8
  end
end
