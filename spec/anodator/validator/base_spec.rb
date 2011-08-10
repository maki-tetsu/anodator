require "spec_helper"

# Anodator::Validator::Base
require "anodator/validator/base"

describe Anodator::Validator::Base, "#new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        Anodator::Validator::Base.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target(nil) parameter" do
    it "should raise ArgumentError" do
      lambda {
        Anodator::Validator::Base.new(nil)
      }.should raise_error ArgumentError
    end
  end

  context "with only target("") parameter" do
    it "should raise ArgumentError" do
      lambda {
        Anodator::Validator::Base.new("")
      }.should raise_error ArgumentError
    end
  end

  context "with only target(34) parameter" do
    before(:each) do
      @new_proc = lambda {
        Anodator::Validator::Base.new("34")
      }
    end

    it "should not raise ArgumentError" do
      @new_proc.should_not raise_error ArgumentError
    end

    it "#allow_blank? should be false" do
      @base = @new_proc.call
      @base.should_not be_allow_blank
    end
  end

  context "with target(name) parameter" do
    context "and allow_blank(true) parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :allow_blank => true)
        }
      end

      it "should not raise ArgumentError" do
        @new_proc.should_not raise_error ArgumentError
      end

      it "#allow_blank? should be true" do
        @base = @new_proc.call
        @base.should be_allow_blank
      end
    end

    context "and allow_blank(false) parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :allow_blank => false)
        }
      end

      it "should not raise ArgumentError" do
        @new_proc.should_not raise_error ArgumentError
      end

      it "#allow_blank? should be false" do
        @base = @new_proc.call
        @base.should_not be_allow_blank
      end
    end

    context "and description parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :description => "description message here.")
        }
      end

      it "should not raise ArgumentError" do
        @new_proc.should_not raise_error ArgumentError
      end

      it "#description should be 'description message here.'" do
        @base = @new_proc.call
        @base.description.should == "description message here."
      end
    end

    context "and unknown parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :unknown => "value")
        }
      end

      it "should raise ArgumentError" do
        @new_proc.should raise_error ArgumentError
      end
    end
  end
end

describe Anodator::Validator::Base, "#validate" do
  it "Anodator::Validator::Base#validate raise NotImplementedError" do
    lambda {
      Anodator::Validator::Base.new("1").validate
    }.should raise_error NoMethodError
  end
end

describe Anodator::Validator::Base, "create a new Validator class to inherit" do
  before(:all) do
    module Anodator
      module Validator
        class SomeValidator < Base
          valid_option_keys :some_option
          default_options :some_option => true
        end
      end
    end
  end

  it "should have additional option" do
    Anodator::Validator::SomeValidator.valid_option_keys.
      should be_include(:some_option)
  end

  it "should have default option ':allow_blank'" do
    Anodator::Validator::SomeValidator.valid_option_keys.
      should be_include(:allow_blank)
  end

  it "should have default value is true for option 'some_option'" do
    Anodator::Validator::SomeValidator.default_options[:some_option].
      should be_true
  end
end

describe Anodator::Validator::Base, "create a new Validator class with unknown defualt options" do
  before(:all) do
    @new_class_proc = lambda {
      module Anodator
        module Validator
          class InvalidDefaultOptionValidator < Base
            valid_option_keys :some_option
            default_options :wrong_option => 11
          end
        end
      end
    }
  end

  it "should raise error" do
    @new_class_proc.should raise_error ArgumentError
  end
end

describe Anodator::Validator::Base, "set values for validation" do
  context "for nil value" do
    it "should raise argument error" do
      lambda {
        Anodator::Validator::Base.values = nil
      }.should raise_error ArgumentError
    end
  end

  context "for String value" do
    it "should not raise argument error" do
      lambda {
        Anodator::Validator::Base.values = "value"
      }.should_not raise_error ArgumentError
    end
  end

  context "for Array values" do
    it "should not raise argument error" do
      lambda {
        Anodator::Validator::Base.values = [1, 2, 3]
      }.should_not raise_error ArgumentError
    end
  end

  context "for Hash values" do
    it "should not raise argument error" do
      lambda {
        Anodator::Validator::Base.values = { "1" => 1, "2" => 2, "3" => 3 }
      }.should_not raise_error ArgumentError
    end
  end

  context "for another values what can respond to [] method" do
    it "should not raise argument error" do
      lambda {
        class Dict
          def []
            return ""
          end
        end
        Anodator::Validator::Base.values = Dict.new
      }.should_not raise_error ArgumentError
    end
  end
end
