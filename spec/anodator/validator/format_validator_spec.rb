require "spec_helper"

# Anodator::Validator::FormatValidator
require "anodator/validator/format_validator"

describe Anodator::Validator::FormatValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        Anodator::Validator::FormatValidator.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target parameter" do
    before(:each) do
      @validator_new_proc = lambda {
        Anodator::Validator::FormatValidator.new("1")
      }
    end

    it "should not raise error" do
      @validator_new_proc.should_not raise_error
    end
  end

  context "with target parameter and :format option" do
    it "should not raise error" do
      lambda {
        Anodator::Validator::FormatValidator.new("1", :format => /^\d+$/)
      }.should_not raise_error
    end
  end

  context "with target parameter and :format option by string" do
    it "should not raise error" do
      lambda {
        Anodator::Validator::FormatValidator.new("1", :format => '\d+')
      }.should_not raise_error
    end

    it "should :format to regexp option" do
      Anodator::Validator::FormatValidator.new("1", :format => '\d+').format.should == /\d+/
    end
  end
end

describe Anodator::Validator::FormatValidator, "#valid?" do
  context "without :format option" do
    before(:each) do
      @validator =
        Anodator::Validator::FormatValidator.new("1", :allow_blank => false)
    end

    it "should raise error" do
      lambda {
        @validator.valid?
      }.should raise_error ConfigurationError
    end
  end

  context "for digit string with no blank" do
    before(:each) do
      @validator =
        Anodator::Validator::FormatValidator.new("1",
                                                 :format => /^\d+$/,
                                                 :allow_blank => false)
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

      it { @validator.should_not be_valid }
    end
  end

  context "for digit string with allow blank" do
    before(:each) do
      @validator =
        Anodator::Validator::FormatValidator.new("1",
                                                 :format => /^\d+$/,
                                                 :allow_blank => true)
    end

    context "target value is blank" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "" }
      end

      it { @validator.should be_valid }
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

      it { @validator.should_not be_valid }
    end
  end

  context "for postal code with not allow blank" do
    before(:each) do
      @validator = Anodator::Validator::FormatValidator.new("postal_code",
                                                            :format => /^\d{3}-\d{4}$/)
    end

    context "target value is valid" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "123-1234" }
      end

      it { @validator.should be_valid }
    end

    context "target value is blank" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "" }
      end

      it { @validator.should_not be_valid }
    end

    context "target value is invalid" do
      before(:each) do
        Anodator::Validator::Base.values = { "postal_code" => "1234567" }
      end

      it { @validator.should_not be_valid }
    end
  end
end
