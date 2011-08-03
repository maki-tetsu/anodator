require "spec_helper"

# Anodator::Validator::InclusionValidator
require "anodator/validator/inclusion_validator"

include Anodator::Validator

describe InclusionValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        InclusionValidator.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    it "should not raise error" do
      lambda {
        InclusionValidator.new("1")
      }.should_not raise_error
    end
  end

  context "with target expression and :in paramerter" do
    before(:each) do
      @new_proc = lambda {
        InclusionValidator.new("1", :in => ["A", "B", "C"])
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":in option must have parameter values" do
      validator = @new_proc.call
      validator.options[:in].should == ["A", "B", "C"]
    end
  end
end

describe InclusionValidator, "#valid?" do
  context "with only target parameter" do
    before(:each) do
      @validator = InclusionValidator.new("1")
    end

    it "should raise error" do
      lambda {
        @validator.valid?
      }.should raise_error ConfigurationError
    end
  end

  context "with target expression and :in paramerter" do
    before(:each) do
      @validator = InclusionValidator.new("1", :in => ["A", "B", "C"])
    end

    context "values for valid" do
      before(:each) do
        Base.values = { "1" => "A" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = { "1" => "D" }
      end

      it { @validator.should_not be_valid }
    end
  end
end
