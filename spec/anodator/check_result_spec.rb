require "spec_helper"

# Anodator::CheckResult
require "anodator/check_result"

include Anodator

RSpec.describe CheckResult, ".new" do
  context "with no parameters" do
    it "should raise error ArgumentError" do
      expect {
        CheckResult.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target_numbers" do
    it "should raise error ArgumentError" do
      expect {
        CheckResult.new(["1", "2"])
      }.to raise_error ArgumentError
    end
  end

  context "with target_numbers and message" do
    before(:each) do
      @new_proc = lambda {
        CheckResult.new(["1", "2"], "An error occured for 1 and 2 values.")
      }
    end

    it "should raise ArgumentError" do
      expect(@new_proc).to raise_error ArgumentError
    end
  end

  context "with target_numbers, message and level" do
    before(:each) do
      @new_proc = lambda {
        CheckResult.new(["1", "2"], "An error occured for 1 and 2 values.", Rule::ERROR_LEVELS[:error])
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    context "after generated" do
      let(:check_result) { @new_proc.call }

      it "#target_numbers should be set" do
        expect(check_result.target_numbers).to be == ["1", "2"]
      end

      it "#message should be set" do
        expect(check_result.message).to be == "An error occured for 1 and 2 values."
      end

      it "#level should be set" do
        expect(check_result.level).to be == Rule::ERROR_LEVELS[:error]
      end
    end
  end
end

RSpec.describe CheckResult, "#error?" do
  context "when level is error" do
    let(:check_result) { CheckResult.new("1", "message", Rule::ERROR_LEVELS[:error]) }

    it {
      pending
      expect(check_result).to be_error
    }
  end

  context "when level is warning" do
    let(:check_result) { CheckResult.new("1", "message", Rule::ERROR_LEVELS[:warning]) }

    it {
      pending
      expect(check_result).not_to be_error
    }
  end
end

RSpec.describe CheckResult, "#warning?" do
  context "when level is error" do
    let(:check_result) { CheckResult.new("1", "message", Rule::ERROR_LEVELS[:error]) }

    it {
      pending
      expect(check_result).not_to be_warning
    }
  end

  context "when level is warning" do
    let(:check_result) { CheckResult.new("1", "message", Rule::ERROR_LEVELS[:warning]) }

    it {
      pending
      expect(check_result).to be_warning
    }
  end
end
