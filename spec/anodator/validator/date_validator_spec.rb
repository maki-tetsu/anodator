require "spec_helper"

# Anodator::Validator::DateValidator
require "anodator/validator/date_validator"

include Anodator::Validator

RSpec.describe DateValidator, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        DateValidator.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target expression" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it { expect(@new_proc.call.format).to be == "YYYY-MM-DD" }
  end

  context "with target expression and :format option" do
    context ":format option is valid" do
      before(:each) do
        @new_proc = lambda {
          DateValidator.new("1", :format => "YYYY/MM/DD")
        }
      end

      it "should not raise error" do
        expect(@new_proc).not_to raise_error
      end

      context "and :from same format" do
        before(:each) do
          @new_proc = lambda {
            DateValidator.new("1", :format => "YYYY/MM/DD", :from => "2011/01/01")
          }
        end

        it "should not raise error" do
          expect(@new_proc).not_to raise_error
        end
      end
    end

    context ":format option contains double YYYY is invalid" do
      before(:each) do
        @new_proc = lambda {
          DateValidator.new("1", :format => "YYYY/MM-DD YYYY")
        }
      end

      it "should raise ArgumentError" do
        expect(@new_proc).to raise_error ArgumentError
      end
    end

    context ":format option not contains D is invalid" do
      before(:each) do
        @new_proc = lambda {
          DateValidator.new("1", :format => "YY/M")
        }
      end

      it "should raise ArgumentError" do
        expect(@new_proc).to raise_error ArgumentError
      end
    end

    context "when :format option contains short year with based on 1900" do
      before(:each) do
        @new_proc = lambda {
          DateValidator.new("Birthday",
                            :format => "M/D/YY", :base_year => 1900,
                            :from => "1/25/80", :to => Date.new(2011, 1, 1))
        }
      end

      it "should not raise error" do
        expect(@new_proc).not_to raise_error
      end

      it "#from should be 1980-01-25" do
        expect(@new_proc.call.from.value).to be == Date.new(1980, 1, 25)
      end

      it "#to should be 2011-01-01" do
        expect(@new_proc.call.to.value).to be == Date.new(2011, 1, 1)
      end
    end
  end

  context "with target expression and :from option with Date object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => Date.new(2011, 1, 1))
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "#from should be date object" do
      expect(@new_proc.call.from.value).to be_a Date
    end
  end

  context "with target expression and :from option with String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => "2011-01-01")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "#from should be date object" do
      expect(@new_proc.call.from.value).to be_a Date
    end

    it "#from should be same date for string expression" do
      expect(@new_proc.call.from.value).to be == Date.new(2011, 1, 1)
    end
  end

  context "with target expression and :from option with invalid format date String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :from => "2011-01-34")
      }
    end

    it "should raise ArgumentError" do
      expect(@new_proc).to raise_error ArgumentError
    end
  end

  context "with target expression and :to option with Date object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => Date.new(2011, 1, 1))
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "#to should be date object" do
      expect(@new_proc.call.to.value).to be_a Date
    end
  end

  context "with target expression and :to option with String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => "2011-01-01")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "#to should be date object" do
      expect(@new_proc.call.to.value).to be_a Date
    end

    it "#to should be same date for string expression" do
      expect(@new_proc.call.to.value).to be == Date.new(2011, 1, 1)
    end
  end

  context "with target expression and :to option with invalid format date String object" do
    before(:each) do
      @new_proc = lambda {
        DateValidator.new("1", :to => "2011-01-34")
      }
    end

    it "should raise ArgumentError" do
      expect(@new_proc).to raise_error ArgumentError
    end
  end
end

RSpec.describe DateValidator, "#valid?" do
  context "with only target expression" do
    let(:validator) { DateValidator.new("1") }

    context "invalid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-34-42" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "valid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-02" }
      end

      it { expect(validator).to be_valid }
    end
  end

  context "with target expression and :from option" do
    let(:validator) { DateValidator.new("1", :from => "2011-04-01") }

    context "invalid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-34-42" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "invalid date by :from option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-03-31" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "valid date by :from option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-01" }
      end

      it { expect(validator).to be_valid }
    end
  end

  context "with target expression and :to option" do
    let(:validator) { DateValidator.new("1", :to => "2011-04-01") }

    context "invalid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-34-42" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "invalid date by :to option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-02" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "valid date by :to option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-01" }
      end

      it { expect(validator).to be_valid }
    end
  end

  context "with target expression and :to and :from option" do
    let(:validator) { DateValidator.new("1", :from => "2010-04-01", :to => "2011-03-31") }

    context "invalid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-34-42" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "invalid date by :from option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2010-03-31" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "invalid date by :to option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-01" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "valid date by :from and :to option" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2010-05-31" }
      end

      it { expect(validator).to be_valid }
    end
  end

  context "with target expression with :allow_blank => true" do
    let(:validator) { DateValidator.new("1", :allow_blank => true) }

    context "invalid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-34-42" }
      end

      it { expect(validator).not_to be_valid }
    end

    context "valid date expression" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "2011-04-02" }
      end

      it { expect(validator).to be_valid }
    end

    context "blank value" do
      before(:each) do
        Anodator::Validator::Base.values = { "1" => "" }
      end

      it { expect(validator).to be_valid }
    end
  end
end
