require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

describe ActiveRelation::Relations::Selection do
  before do
    @relation1 = ActiveRelation::Relations::Table.new(:foo)
    @relation2 = ActiveRelation::Relations::Table.new(:bar)
    @predicate1 = ActiveRelation::Predicates::Equality.new(@relation1[:id], @relation2[:foo_id])
    @predicate2 = ActiveRelation::Predicates::LessThan.new(@relation1[:age], 2)
  end
  
  describe '#initialize' do
    it "manufactures nested selection relations if multiple predicates are provided" do
      ActiveRelation::Relations::Selection.new(@relation1, @predicate1, @predicate2). \
        should == ActiveRelation::Relations::Selection.new(ActiveRelation::Relations::Selection.new(@relation1, @predicate2), @predicate1)
    end
  end
  
  describe '#qualify' do
    it "distributes over the relation and predicates" do
      ActiveRelation::Relations::Selection.new(@relation1, @predicate1).qualify. \
        should == ActiveRelation::Relations::Selection.new(@relation1.qualify, @predicate1.qualify)
    end
  end
  
  describe '#to_sql' do
    it "manufactures sql with where clause conditions" do
      ActiveRelation::Relations::Selection.new(@relation1, @predicate1).to_sql.should be_like("""
        SELECT `foo`.`name`, `foo`.`id`
        FROM `foo`
        WHERE `foo`.`id` = `bar`.`foo_id`
      """)
    end
    
    it "allows arbitrary sql" do
      ActiveRelation::Relations::Selection.new(@relation1, "asdf").to_sql.should be_like("""
        SELECT `foo`.`name`, `foo`.`id`
        FROM `foo`
        WHERE asdf
      """)
    end
  end
end