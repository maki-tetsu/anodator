require "spec_helper"

# Anodator::Validator::NumericValidator
require "anodator/validator/numeric_validator"

include Anodator::Validator

RSpec.describe NumericValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        NumericValidator.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target expression" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":only_integer option must be false by default option" do
      expect(@new_proc.call.options[:only_integer]).to be_falsey
    end
  end

  context "with target expression and :only_integer" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :only_integer => true)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":only_integer option must be exists" do
      expect(@new_proc.call.options[:only_integer]).to be_truthy
    end
  end

  context "with target expression and :greater_than" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :greater_than => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":greater_than option must be exists" do
      expect(@new_proc.call.options[:greater_than].value).to be == 10
    end
  end

  context "with target expression and :greater_than_or_equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :greater_than_or_equal_to => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":greater_than_or_equal_to option must be exists" do
      expect(@new_proc.call.options[:greater_than_or_equal_to].value).to be == 10
    end
  end

  context "with target expression and :less_than" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :less_than => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":less_than option must be exists" do
      expect(@new_proc.call.options[:less_than].value).to be == 10
    end
  end

  context "with target expression and :less_than_or_equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :less_than_or_equal_to => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":less_than_or_equal_to option must be exists" do
      expect(@new_proc.call.options[:less_than_or_equal_to].value).to be == 10
    end
  end

  context "with target expression and :equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :equal_to => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":equal_to option must be exists" do
      expect(@new_proc.call.options[:equal_to].value).to be == 10
    end
  end

  context "with target expression and :not_equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :not_equal_to => 10)
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it ":not_equal_to option must be exists" do
      expect(@new_proc.call.options[:not_equal_to].value).to be == 10
    end
  end
end

RSpec.describe NumericValidator, "#valid?" do
  context "with only target expression" do
    let(:validator) { NumericValidator.new("1") }

    context "values for valid integer" do
      before(:each) do
        Base.values = { "1" => "132" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "132.42" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid character" do
      before(:each) do
        Base.values = { "1" => "abdcd" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid number include alphabet" do
      before(:each) do
        Base.values = { "1" => "124.43fsd" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for valid negative integer" do
      before(:each) do
        Base.values = { "1" => "-312" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid negative floating point value" do
      before(:each) do
        Base.values = { "1" => "-13.442" }
      end

      it { expect(validator).to be_valid }
    end
  end

  context "with target expression and :only_integer" do
    let(:validator) { NumericValidator.new("1", :only_integer => true) }

    context "values for valid integer" do
      before(:each) do
        Base.values = { "1" => "3252" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid floating point vlaue" do
      before(:each) do
        Base.values = { "1" => "42.43" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :greater_than" do
    let(:validator) { NumericValidator.new("1", :greater_than => 10) }

    context "values for valid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "10.00001" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid maximum floating potin value" do
      before(:each) do
        Base.values = { "1" => "9.999999" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :greater_than_or_equal_to" do
    let(:validator) { NumericValidator.new("1", :greater_than_or_equal_to => 10) }

    context "values for valid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0001" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid maximum floating potin value" do
      before(:each) do
        Base.values = { "1" => "9.999999" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :less_than" do
    let(:validator) { NumericValidator.new("1", :less_than => 10) }

    context "values for valid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :less_than_or_equal_to" do
    let(:validator) { NumericValidator.new("1", :less_than_or_equal_to => 10) }

    context "values for valid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :equal_to" do
    let(:validator) { NumericValidator.new("1", :equal_to => 10) }

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context "with target expression and :not_equal_to" do
    let(:validator) { NumericValidator.new("1", :not_equal_to => 10) }

    context "values for valid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for invalid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for invalid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "values for valid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { expect(validator).to be_valid }
    end

    context "values for valid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { expect(validator).to be_valid }
    end
  end
end
