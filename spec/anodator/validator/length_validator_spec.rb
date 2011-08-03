require "spec_helper"

# Anodator::Validator::LengthValidator
require "anodator/validator/length_validator"

include Anodator::Validator

describe LengthValidator, ".new" do
  context "with no paramerters" do
    it "should raise error" do
      lambda {
        LengthValidator.new()
      }.should raise_error
    end
  end

  context "with only target expression" do
    it "should not raise error" do
      lambda {
        LengthValidator.new("1")
      }.should_not raise_error
    end
  end

  context "with target expression and :maximum parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :maximum => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "should have :maximum option value" do
      validator = @new_proc.call
      validator.options[:maximum].should == 10
    end
  end

  context "with target expression and :minimum parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :minimum => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "should have :minimum option value" do
      validator = @new_proc.call
      validator.options[:minimum].should == 10
    end
  end

  context "with target expression and :is parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :is => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "should have :is option value" do
      validator = @new_proc.call
      validator.options[:is].should == 10
    end
  end

  context "with target expression and :in parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :in => 3..6)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "should have :in option value" do
      validator = @new_proc.call
      validator.options[:in].should == (3..6)
    end
  end
end

describe LengthValidator, "#valid?" do
  context "with only target expression" do
    before(:each) do
      @validator = LengthValidator.new("1")
      Base.values = {
        "1" => "string",
        "2" => "string",
        "3" => "string",
        "4" => "string",
      }
    end

    it "should not raise error" do
      lambda {
        @validator.valid?
      }.should_not raise_error
    end
  end

  context "with target expression and :maximum parameters" do
    before(:each) do
      @validator = LengthValidator.new("1", :maximum => 10)
    end

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "12345678901"
        }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :minimum parameters" do
    before(:each) do
      @validator = LengthValidator.new("1", :minimum => 10)
    end

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "123456789"
        }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :is parameters" do
    before(:each) do
      @validator = LengthValidator.new("1", :is => 10)
    end

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "123456789"
        }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :in parameters" do
    before(:each) do
      @validator = LengthValidator.new("1", :in => 3..6)
    end

    context "values for minimum equal valid" do
      before(:each) do
        Base.values = {
          "1" => "123"
        }
      end

      it { @validator.should be_valid }
    end

    context "values for minimum invalid" do
      before(:each) do
        Base.values = {
          "1" => "12"
        }
      end

      it { @validator.should_not be_valid }
    end

    context "values for maximum equal valid" do
      before(:each) do
        Base.values = {
          "1" => "123456"
        }
      end

      it { @validator.should be_valid }
    end

    context "values for maximum invalid" do
      before(:each) do
        Base.values = {
          "1" => "1234567"
        }
      end

      it { @validator.should_not be_valid }
    end
  end
end
