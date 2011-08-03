require "spec_helper"

# Anodator::Validator::NumericValidator
require "anodator/validator/numeric_validator"

include Anodator::Validator

describe NumericValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        NumericValidator.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target expression" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":only_integer option must be false by default option" do
      @new_proc.call.options[:only_integer].should == false
    end
  end

  context "with target expression and :only_integer" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :only_integer => true)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":only_integer option must be exists" do
      @new_proc.call.options[:only_integer].should == true
    end
  end

  context "with target expression and :greater_than" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :greater_than => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":greater_than option must be exists" do
      @new_proc.call.options[:greater_than].should == 10
    end
  end

  context "with target expression and :greater_than_or_equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :greater_than_or_equal_to => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":greater_than_or_equal_to option must be exists" do
      @new_proc.call.options[:greater_than_or_equal_to].should == 10
    end
  end

  context "with target expression and :less_than" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :less_than => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":less_than option must be exists" do
      @new_proc.call.options[:less_than].should == 10
    end
  end

  context "with target expression and :less_than_or_equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :less_than_or_equal_to => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":less_than_or_equal_to option must be exists" do
      @new_proc.call.options[:less_than_or_equal_to].should == 10
    end
  end

  context "with target expression and :equal_to" do
    before(:each) do
      @new_proc = lambda {
        NumericValidator.new("1", :equal_to => 10)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it ":equal_to option must be exists" do
      @new_proc.call.options[:equal_to].should == 10
    end
  end
end

describe NumericValidator, "#valid?" do
  context "with only target expression" do
    before(:each) do
      @validator = NumericValidator.new("1")
    end

    context "values for valid integer" do
      before(:each) do
        Base.values = { "1" => "132" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "132.42" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid character" do
      before(:each) do
        Base.values = { "1" => "abdcd" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid number include alphabet" do
      before(:each) do
        Base.values = { "1" => "124.43fsd" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :only_integer" do
    before(:each) do
      @validator = NumericValidator.new("1", :only_integer => true)
    end

    context "values for valid integer" do
      before(:each) do
        Base.values = { "1" => "3252" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid floating point vlaue" do
      before(:each) do
        Base.values = { "1" => "42.43" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :greater_than" do
    before(:each) do
      @validator = NumericValidator.new("1", :greater_than => 10)
    end

    context "values for valid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "10.00001" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid maximum floating potin value" do
      before(:each) do
        Base.values = { "1" => "9.999999" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :greater_than_or_equal_to" do
    before(:each) do
      @validator = NumericValidator.new("1", :greater_than_or_equal_to => 10)
    end

    context "values for valid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0001" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid maximum floating potin value" do
      before(:each) do
        Base.values = { "1" => "9.999999" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :less_than" do
    before(:each) do
      @validator = NumericValidator.new("1", :less_than => 10)
    end

    context "values for valid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :less_than_or_equal_to" do
    before(:each) do
      @validator = NumericValidator.new("1", :less_than_or_equal_to => 10)
    end

    context "values for valid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { @validator.should_not be_valid }
    end
  end

  context "with target expression and :equal_to" do
    before(:each) do
      @validator = NumericValidator.new("1", :equal_to => 10)
    end

    context "values for invalid maximum value" do
      before(:each) do
        Base.values = { "1" => "9" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid maximum floating point value" do
      before(:each) do
        Base.values = { "1" => "9.9999999" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for valid equal value" do
      before(:each) do
        Base.values = { "1" => "10" }
      end

      it { @validator.should be_valid }
    end

    context "values for valid equal floating point value" do
      before(:each) do
        Base.values = { "1" => "10.0" }
      end

      it { @validator.should be_valid }
    end

    context "values for invalid minimum value" do
      before(:each) do
        Base.values = { "1" => "11" }
      end

      it { @validator.should_not be_valid }
    end

    context "values for invalid minimum floating potin value" do
      before(:each) do
        Base.values = { "1" => "10.0000001" }
      end

      it { @validator.should_not be_valid }
    end
  end
end
