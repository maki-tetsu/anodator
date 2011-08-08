require "spec_helper"

# Anodator::InputSpecItem
require "anodator/input_spec_item"

include Anodator

describe InputSpecItem, ".new" do
  context "with no parameter" do
    it "should raise error ArgumentError" do
      lambda {
        InputSpecItem.new
      }.should raise_error ArgumentError
    end
  end

  context "with only number parameter" do
    it "should raise ArgumentError" do
      lambda {
        InputSpecItem.new("1")
      }.should raise_error ArgumentError
    end
  end

  context "with blank number parameter" do
    it "should raise ArgumentError" do
      lambda {
        InputSpecItem.new("", "item_1")
      }.should raise_error ArgumentError
    end
  end

  context "with nil number parameter" do
    it "should raise ArgumentError" do
      lambda {
        InputSpecItem.new(nil, "item_1")
      }.should raise_error ArgumentError
    end
  end

  context "with blank name parameter" do
    it "should raise ArgumentError" do
      lambda {
        InputSpecItem.new("1", "")
      }.should raise_error ArgumentError
    end
  end

  context "with nil name parameter" do
    it "should raise ArgumentError" do
      lambda {
        InputSpecItem.new("1", nil)
      }.should raise_error ArgumentError
    end
  end

  context "with number and name parameter" do
    before(:all) do
      @new_proc = lambda {
        InputSpecItem.new("1", "item_1")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:all) do
        @input_spec_item = @new_proc.call
      end

      it { @input_spec_item.number.should == "1" }
      it { @input_spec_item.name.should == "item_1" }
    end
  end
end
