require "spec_helper"

# Anodator::Validator::PresenceValidator
require "anodator/validator/presence_validator"

RSpec.describe Anodator::Validator::PresenceValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        Anodator::Validator::PresenceValidator.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    it "should not raise error" do
      expect {
        Anodator::Validator::PresenceValidator.new("1")
      }.not_to raise_error
    end
  end
end

RSpec.describe Anodator::Validator::PresenceValidator, "#valid?" do
  let(:validator) { Anodator::Validator::PresenceValidator.new("1") }

  context "target value is blank" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "" }
    end

    it { expect(validator).not_to be_valid }
  end

  context "target value is '1'" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "1" }
    end

    it { expect(validator).to be_valid }
  end

  context "target value is 'some message'" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "some message" }
    end

    it { expect(validator).to be_valid }
  end
end
