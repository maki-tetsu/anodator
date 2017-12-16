require "spec_helper"

# Anodator::Validator::InclusionValidator
require "anodator/validator/inclusion_validator"

include Anodator::Validator

RSpec.describe InclusionValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        InclusionValidator.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    it "should not raise error" do
      expect {
        InclusionValidator.new("1")
      }.not_to raise_error
    end
  end

  context "with target expression and :in paramerter" do
    before(:each) do
      @new_proc = lambda {
        InclusionValidator.new("1", :in => ["A", "B", "C"])
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":in option must have parameter values" do
      validator = @new_proc.call
      expect(validator.options[:in]).to be == ["A", "B", "C"]
    end
  end
end

RSpec.describe InclusionValidator, "#valid?" do
  context "with only target parameter" do
    before(:each) do
      @validator = InclusionValidator.new("1")
    end

    it "should raise error" do
      expect {
        @validator.valid?
      }.to raise_error ConfigurationError
    end
  end

  context "with target expression and :in paramerter" do
    let(:validator) { InclusionValidator.new("1", :in => ["A", "B", "C"]) }

    context "values for valid" do
      before(:each) do
        Base.values = { "1" => "A" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = { "1" => "D" }
      end

      it { expect(validator).not_to be_valid }
    end
  end
end
