require "spec_helper"

# Anodator::InputSpecItem
require "anodator/input_spec_item"

include Anodator

RSpec.describe InputSpecItem, ".new" do
  context "with no parameter" do
    it "should raise error ArgumentError" do
      expect {
        InputSpecItem.new
      }.to raise_error ArgumentError
    end
  end

  context "with only number parameter" do
    it "should raise ArgumentError" do
      expect {
        InputSpecItem.new("1")
      }.to raise_error ArgumentError
    end
  end

  context "with blank number parameter" do
    it "should raise ArgumentError" do
      expect {
        InputSpecItem.new("", "item_1")
      }.to raise_error ArgumentError
    end
  end

  context "with nil number parameter" do
    it "should raise ArgumentError" do
      expect {
        InputSpecItem.new(nil, "item_1")
      }.to raise_error ArgumentError
    end
  end

  context "with blank name parameter" do
    it "should raise ArgumentError" do
      expect {
        InputSpecItem.new("1", "")
      }.to raise_error ArgumentError
    end
  end

  context "with nil name parameter" do
    it "should raise ArgumentError" do
      expect {
        InputSpecItem.new("1", nil)
      }.to raise_error ArgumentError
    end
  end

  context "with number and name parameter" do
    before(:all) do
      @new_proc = lambda {
        InputSpecItem.new("1", "item_1")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    context "after generated" do
      before(:all) do
        @input_spec_item = @new_proc.call
      end

      it { expect(@input_spec_item.number).to be == "1" }
      it { expect(@input_spec_item.name).to be == "item_1" }
      it { expect(@input_spec_item.type).to be == "STRING" }
    end
  end

  context "with number, name and type(NUMERIC) parameter" do
    before(:all) do
      @new_proc = lambda {
        InputSpecItem.new("1", "item_1", "NUMERIC")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    context "after generated" do
      before(:all) do
        @input_spec_item = @new_proc.call
      end

      it { expect(@input_spec_item.number).to be == "1" }
      it { expect(@input_spec_item.name).to be == "item_1" }
      it { expect(@input_spec_item.type).to be == "NUMERIC" }
    end
  end
end
