require "spec_helper"

# Anodator::Validator::Base
require "anodator/validator/base"

RSpec.describe Anodator::Validator::Base, "#new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      expect {
        Anodator::Validator::Base.new
      }.to raise_error ArgumentError
    end
  end

  context "with only target(nil) parameter" do
    it "should raise ArgumentError" do
      expect {
        Anodator::Validator::Base.new(nil)
      }.to raise_error ArgumentError
    end
  end

  context "with only target("") parameter" do
    it "should raise ArgumentError" do
      expect {
        Anodator::Validator::Base.new("")
      }.to raise_error ArgumentError
    end
  end

  context "with only target(34) parameter" do
    before(:each) do
      @new_proc = lambda {
        Anodator::Validator::Base.new("34")
      }
    end

    it "should not raise error" do
      expect(@new_proc).not_to raise_error
    end

    it "#allow_blank? should be false" do
      @base = @new_proc.call
      expect(@base).not_to be_allow_blank
    end
  end

  context "with target(name) parameter" do
    context "and allow_blank(true) parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :allow_blank => true)
        }
      end

      it "should not raise error" do
        expect(@new_proc).not_to raise_error
      end

      it "#allow_blank? should be true" do
        @base = @new_proc.call
        expect(@base).to be_allow_blank
      end
    end

    context "and allow_blank(false) parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :allow_blank => false)
        }
      end

      it "should not raise error" do
        expect(@new_proc).not_to raise_error
      end

      it "#allow_blank? should be false" do
        @base = @new_proc.call
        expect(@base).not_to be_allow_blank
      end
    end

    context "and description parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :description => "description message here.")
        }
      end

      it "should not raise error" do
        expect(@new_proc).not_to raise_error
      end

      it "#description should be 'description message here.'" do
        @base = @new_proc.call
        expect(@base.description).to be == "description message here."
      end
    end

    context "and unknown parameter" do
      before(:each) do
        @new_proc = lambda {
          Anodator::Validator::Base.new("name", :unknown => "value")
        }
      end

      it "should raise ArgumentError" do
        expect(@new_proc).to raise_error ArgumentError
      end
    end
  end
end

RSpec.describe Anodator::Validator::Base, "#validate" do
  it "Anodator::Validator::Base#validate raise NotImplementedError" do
    expect {
      Anodator::Validator::Base.new("1").validate
    }.to raise_error NoMethodError
  end
end

RSpec.describe Anodator::Validator::Base, "create a new Validator class to inherit" do
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
    expect(Anodator::Validator::SomeValidator.valid_option_keys).to include(:some_option)
  end

  it "should have default option ':allow_blank'" do
    expect(Anodator::Validator::SomeValidator.valid_option_keys).to include(:allow_blank)
  end

  it "should have default value is true for option 'some_option'" do
    expect(Anodator::Validator::SomeValidator.default_options[:some_option]).to be_truthy
  end
end

RSpec.describe Anodator::Validator::Base, "create a new Validator class with unknown defualt options" do
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
    expect(@new_class_proc).to raise_error ArgumentError
  end
end

RSpec.describe Anodator::Validator::Base, "set values for validation" do
  context "for nil value" do
    it "should raise argument error" do
      expect {
        Anodator::Validator::Base.values = nil
      }.to raise_error ArgumentError
    end
  end

  context "for String value" do
    it "should not raise error" do
      expect {
        Anodator::Validator::Base.values = "value"
      }.not_to raise_error
    end
  end

  context "for Array values" do
    it "should not raise error" do
      expect {
        Anodator::Validator::Base.values = [1, 2, 3]
      }.not_to raise_error
    end
  end

  context "for Hash values" do
    it "should not raise error" do
      expect {
        Anodator::Validator::Base.values = { "1" => 1, "2" => 2, "3" => 3 }
      }.not_to raise_error
    end
  end

  context "for another values what can respond to [] method" do
    it "should not raise error" do
      expect {
        class Dict
          def []
            return ""
          end
        end
        Anodator::Validator::Base.values = Dict.new
      }.not_to raise_error
    end
  end
end
