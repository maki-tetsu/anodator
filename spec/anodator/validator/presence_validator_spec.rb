require "spec_helper"

# Anodator::Validator::PresenceValidator
require "anodator/validator/presence_validator"

describe Anodator::Validator::PresenceValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        Anodator::Validator::PresenceValidator.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    it "should not raise error" do
      lambda {
        Anodator::Validator::PresenceValidator.new("1")
      }.should_not raise_error
    end
  end
end

describe Anodator::Validator::PresenceValidator, "#valid?" do
  before(:each) do
    @validator = Anodator::Validator::PresenceValidator.new("1")
  end

  context "target value is blank" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "" }
    end

    it { @validator.should_not be_valid }
  end

  context "target value is '1'" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "1" }
    end

    it { @validator.should be_valid }
  end

  context "target value is 'some message'" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "some message" }
    end

    it { @validator.should be_valid }
  end
end
