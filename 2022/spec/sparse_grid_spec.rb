require_relative '../15.rb'
describe Day15::SparseGrid do
  context "adding values" do
    it "changes size by 1 as items are added" do
      g = Day15::SparseGrid.new
      g.add_value(10, 90, 1)
      expect(g.rows).to eq(1)
      expect(g.cols).to eq(1)
      expect(g.value_at(10,90)).to eq(1)
    end
    it "changes col by 1 if x coord is greater than existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 90, 1)
      rows = g.rows
      g.add_value(20, 90, 2)
      expect(g.rows).to eq(rows)
      expect(g.cols).to eq(2)
      expect(g.value_at(10,90)).to eq(1)
      expect(g.value_at(20,90)).to eq(2)
    end
    it "changes row by 1 if y coord is greater than existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 90, 1)
      cols = g.cols
      g.add_value(10, 100, 2)
      expect(g.cols).to eq(cols)
      expect(g.rows).to eq(2)
      expect(g.value_at(10,90)).to eq(1)
      expect(g.value_at(10,100)).to eq(2)
    end
    it "changes col by 1 if x coord is less than existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 90, 1)
      rows = g.rows
      g.add_value(5, 90, 2)
      expect(g.rows).to eq(rows)
      expect(g.cols).to eq(2)
      expect(g.value_at(5,90)).to eq(2)
      expect(g.value_at(10,90)).to eq(1)
    end
    it "changes row by 1 if y coord is less than existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 90, 1)
      cols = g.cols
      g.add_value(10, 80, 2)
      expect(g.cols).to eq(cols)
      expect(g.rows).to eq(2)
      expect(g.value_at(10,90)).to eq(1)
      expect(g.value_at(10,80)).to eq(2)
    end
    it "changes row by 1 if y coord is in between existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 10, 1)
      g.add_value(10, 30, 2)
      g.add_value(10, 20, 4)
      expect(g.cols).to eq(1)
      expect(g.rows).to eq(3)
      expect(g.value_at(10,10)).to eq(1)
      expect(g.value_at(10,30)).to eq(2)
      expect(g.value_at(10,20)).to eq(4)
    end
    it "changes col by 1 if x coord is in between existing" do
      g = Day15::SparseGrid.new
      g.add_value(10, 10, 1)
      g.add_value(30, 10, 2)
      g.add_value(20, 10, 4)
      expect(g.cols).to eq(3)
      expect(g.rows).to eq(1)
      expect(g.value_at(10,10)).to eq(1)
      expect(g.value_at(30,10)).to eq(2)
      expect(g.value_at(20,10)).to eq(4)
    end
    it "adds value to existing coord" do
      g = Day15::SparseGrid.new
      g.add_value(10, 10, 1)
      g.add_value(10, 10, 2)
      expect(g.value_at(10,10) & 1).to be > 0
      expect(g.value_at(10,10) & 2).to be > 0
      expect(g.value_at(10,10) & 4).to eq(0)
    end
  end
end
