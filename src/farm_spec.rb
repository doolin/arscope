require './arscope'

describe Farm do
  before :all do
    # Nasty kludge. You can do better than this.
    require './seed'
  end

  let(:farm) { Farm.new }

  it "creates a valid farm" do
    expect(farm).to be_valid
  end

  it "finds a Funny farm" do
    Farm.where(name: 'Funny').first.should be_valid
  end

  it "Funny Farm finds four animals" do
    funny_farm = Farm.where(name: 'Funny').first
    expect(funny_farm.animals.size).to eq 8
  end
end
