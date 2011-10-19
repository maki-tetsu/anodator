require "spec_helper"

# Anodator::CheckResult
require "anodator/check_result"

include Anodator

describe CheckResult, ".new" do
  context "with no parameters" do
    it "should raise error ArgumentError" do
      lambda {
        CheckResult.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target_numbers" do
    it "should raise error ArgumentError" do
      lambda {
        CheckResult.new(["1", "2"])
      }.should raise_error ArgumentError
    end
  end

  context "with target_numbers and message" do
    before(:each) do
      @new_proc = lambda {
        CheckResult.new(["1", "2"], "An error occured for 1 and 2 values.")
      }
    end

    it "should raise ArgumentError" do
      @new_proc.should raise_error ArgumentError
    end
  end
  context "with target_numbers, message and level" do
    before(:each) do
      @new_proc = lambda {
        CheckResult.new(["1", "2"], "An error occured for 1 and 2 values.", Rule::ERROR_LEVELS[:error])
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @check_result = @new_proc.call
      end

      it "#target_numbers should be set" do
        @check_result.target_numbers.should == ["1", "2"]
      end

      it "#message should be set" do
        @check_result.message.should == "An error occured for 1 and 2 values."
      end

      it "#level should be set" do
        @check_result.level.should == Rule::ERROR_LEVELS[:error]
      end
    end
  end
end

describe CheckResult, "#error?" do
  context "when level is error" do
    before(:each) do
      @check_result = CheckResult.new("1", "message", Rule::ERROR_LEVELS[:error])
    end

    it { @check_result.should be_error }
  end

  context "when level is warning" do
    before(:each) do
      @check_result = CheckResult.new("1", "message", Rule::ERROR_LEVELS[:warning])
    end

    it { @check_result.should_not be_error }
  end
end

describe CheckResult, "#warning?" do
  context "when level is error" do
    before(:each) do
      @check_result = CheckResult.new("1", "message", Rule::ERROR_LEVELS[:error])
    end

    it { @check_result.should_not be_warning }
  end

  context "when level is warning" do
    before(:each) do
      @check_result = CheckResult.new("1", "message", Rule::ERROR_LEVELS[:warning])
    end

    it { @check_result.should be_warning }
  end
end
