require "spec_helper"

# Anodator::Validator::DateValidator
require "anodator/validator/date_validator"

include Anodator::Validator

describe DateValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        DateValidator.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target expression" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end
  end

  context "with target expression and :from option with Date object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => Date.new(2011, 1, 1))
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#from should be date object" do
      @new_proc.call.from.should be_a Date
    end
  end

  context "with target expression and :from option with String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => "2011/01/01")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#from should be date object" do
      @new_proc.call.from.should be_a Date
    end

    it "#from should be same date for string expression" do
      @new_proc.call.from.should == Date.new(2011, 1, 1)
    end
  end

  context "with target expression and :from option with invalid format date String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => "2011/01/34")
      }
    end

    it "should raise ArgumentError" do
      @new_proc.should raise_error ArgumentError
    end
  end

  context "with target expression and :to option with Date object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => Date.new(2011, 1, 1))
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#to should be date object" do
      @new_proc.call.to.should be_a Date
    end
  end

  context "with target expression and :to option with String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => "2011/01/01")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#to should be date object" do
      @new_proc.call.to.should be_a Date
    end

    it "#to should be same date for string expression" do
      @new_proc.call.to.should == Date.new(2011, 1, 1)
    end
  end

  context "with target expression and :to option with invalid format date String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => "2011/01/34")
      }
    end

    it "should raise ArgumentError" do
      @new_proc.should raise_error ArgumentError
    end
  end
end

describe DateValidator, "#valid?" do
  context "with only target expression" do
    before(:each) do
      @validator = DateValidator.new("1")
    end

    context "invalid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/34/42" }
      end

      it { @validator.should_not be_valid }
    end

    context "valid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/04/02" }
      end

      it { @validator.should be_valid }
    end
  end

  context "with target expression and :from option" do
    before(:each) do
      @validator = DateValidator.new("1", :from => "2011/04/01")
    end

    context "invalid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/34/42" }
      end

      it { @validator.should_not be_valid }
    end

    context "invalid date by :from option" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/03/31" }
      end

      it { @validator.should_not be_valid }
    end

    context "valid date by :from option" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/04/01" }
      end

      it { @validator.should be_valid }
    end
  end

  context "with target expression and :to option" do
    before(:each) do
      @validator = DateValidator.new("1", :to => "2011/04/01")
    end

    context "invalid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/34/42" }
      end

      it { @validator.should_not be_valid }
    end

    context "invalid date by :to option" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/04/02" }
      end

      it { @validator.should_not be_valid }
    end

    context "valid date by :to option" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/04/01" }
      end

      it { @validator.should be_valid }
    end
  end

  context "with target expression with :allow_blank => true" do
    before(:each) do
      @validator = DateValidator.new("1", :allow_blank => true)
    end

    context "invalid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/34/42" }
      end

      it { @validator.should_not be_valid }
    end

    context "valid date expression" do
      before(:each) do
        Validator::Base.values = { "1" => "2011/04/02" }
      end

      it { @validator.should be_valid }
    end

    context "blank value" do
      before(:each) do
        Validator::Base.values = { "1" => "" }
      end

      it { @validator.should be_valid }
    end
  end
end
