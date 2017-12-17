require "spec_helper"

# Anodator::Validator::LengthValidator
require "anodator/validator/length_validator"

include Anodator::Validator

RSpec.describe LengthValidator, ".new" do
  context "with no paramerters" do
    it "should raise error" do
      expect {
        LengthValidator.new()
      }.to raise_error ArgumentError
    end
  end

  context "with only target expression" do
    it "should not raise error" do
      expect {
        LengthValidator.new("1")
      }.not_to raise_error
    end
  end

  context "with target expression and :maximum parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :maximum => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "should have :maximum option value" do
      validator = @new_proc.call
      expect(validator.options[:maximum].value).to be == 10
    end
  end

  context "with target expression and :minimum parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :minimum => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "should have :minimum option value" do
      validator = @new_proc.call
      expect(validator.options[:minimum].value).to be == 10
    end
  end

  context "with target expression and :is parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :is => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "should have :is option value" do
      validator = @new_proc.call
      expect(validator.options[:is].value).to be == 10
    end
  end

  context "with target expression and :in parameters" do
    before(:each) do
      @new_proc = lambda {
        LengthValidator.new("1", :in => 3..6)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "should have :in option value" do
      validator = @new_proc.call
      expect(validator.options[:in]).to be == (3..6)
    end
  end
end

RSpec.describe LengthValidator, "#valid?" do
  context "with only target expression" do
    let(:validator) { LengthValidator.new("1") }
    before(:each) do
      Base.values = {
        "1" => "string",
        "2" => "string",
        "3" => "string",
        "4" => "string",
      }
    end

    it "should not raise error" do
      expect { validator.valid? }.not_to raise_error
    end
  end

  context "with target expression and :maximum parameters" do
    let(:validator) { LengthValidator.new("1", :maximum => 10) }

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "12345678901"
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :minimum parameters" do
    let(:validator) { LengthValidator.new("1", :minimum => 10) }

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "123456789"
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :is parameters" do
    let(:validator) { LengthValidator.new("1", :is => 10) }

    context "values for valid" do
      before(:each) do
        Base.values = {
          "1" => "1234567890"
        }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid" do
      before(:each) do
        Base.values = {
          "1" => "123456789"
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :in parameters" do
    let(:validator) { LengthValidator.new("1", :in => 3..6) }

    context "values for minimum equal valid" do
      before(:each) do
        Base.values = {
          "1" => "123"
        }
      end

      it { expect(validator).to be_valid }
    end

    context "values for minimum invalid" do
      before(:each) do
        Base.values = {
          "1" => "12"
        }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for maximum equal valid" do
      before(:each) do
        Base.values = {
          "1" => "123456"
        }
      end

      it { expect(validator).to be_valid }
    end

    context "values for maximum invalid" do
      before(:each) do
        Base.values = {
          "1" => "1234567"
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end
end
