require "spec_helper"

# Anodator::Validator::FormatValidator
require "anodator/validator/format_validator"

RSpec.describe Anodator::Validator::FormatValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        Anodator::Validator::FormatValidator.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    before(:each) do
      @validator_new_proc = lambda {
        Anodator::Validator::FormatValidator.new("1")
      }
    end

    it "should not raise error" do
      expect(@validator_new_proc).not_to raise_error
    end
  end

  context "with target parameter and :format option" do
    it "should not raise error" do
      expect {
        Anodator::Validator::FormatValidator.new("1", :format => /^\d+$/)
      }.not_to raise_error
    end
  end

  context "with target parameter and :format option by string" do
    it "should not raise error" do
      expect {
        Anodator::Validator::FormatValidator.new("1", :format => '\d+')
      }.not_to raise_error
    end

    it "should :format to regexp option" do
      expect(Anodator::Validator::FormatValidator.new("1", :format => '\d+').format).to be == /\d+/
    end
  end
end

RSpec.describe Anodator::Validator::FormatValidator, "#valid?" do
  context "without :format option" do
    before(:each) do
      Anodator::Validator::Base.values = { "1" => "" }
      @validator =
        Anodator::Validator::FormatValidator.new("1", :allow_blank => false)
    end

    it "should raise error" do
      expect {
        @validator.valid?
      }.to raise_error Anodator::Validator::ConfigurationError
    end
  end

  context "for digit string with no blank" do
    let(:validator) {
      Anodator::Validator::FormatValidator.new("1",
                                               :format => /^\d+$/,
                                               :allow_blank => false)
    }

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

      it { expect(validator).not_to be_valid }
    end
  end

  context "for digit string with allow blank" do
    let(:validator) {
      Anodator::Validator::FormatValidator.new("1",
                                               :format => /^\d+$/,
                                               :allow_blank => true)
    }

    context "target value is blank" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "" }
      end

      it { expect(validator).to be_valid }
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

      it { expect(validator).not_to be_valid }
    end
  end

  context "for postal code with not allow blank" do
    let(:validator) {
      Anodator::Validator::FormatValidator.new("postal_code", :format => /^\d{3}-\d{4}$/)
    }

    context "target value is valid" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "123-1234" }
      end

      it { expect(validator).to be_valid }
    end

    context "target value is blank" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "target value is invalid" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "1234567" }
      end

      it { expect(validator).not_to be_valid }
    end
  end
end
