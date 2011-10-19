require "spec_helper"

# Anodator::Rule
require "anodator/rule"

include Anodator

describe Rule, "#new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        Rule.new
      }.should raise_error ArgumentError
    end
  end

  context "with only target_expressions" do
    it "should raise ArgumentError" do
      lambda {
        Rule.new(["1", "2", "3"])
      }.should raise_error ArgumentError
    end
  end

  context "with target_expressions and message" do
    it "should raise ArgumentError" do
      lambda {
        Rule.new(["1", "2", "3"],
                 Message.new("'[[1::name]]' cannot be blank"))
      }.should raise_error ArgumentError
    end
  end

  context "with target_expressions, message and validator" do
    before(:each) do
      @new_proc = lambda {
        v1 = Validator::PresenceValidator.new("1")
        v2 = Validator::PresenceValidator.new("2")
        @validator = Validator::ComplexValidator.new(:validators => [v1, v2])
        @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
        Rule.new(["1", "2"], @message, @validator)
      }
    end

    it "should not raise Error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @rule = @new_proc.call
      end

      it "#target_expressions should equal by initialize" do
        @rule.target_expressions.should == ["1", "2"]
      end

      it "#message should equal by initialize" do
        @rule.message.should == @message
      end

      it "#validator should equal by initialize" do
        @rule.validator.should == @validator
      end

      it "#prerequisite should be nil" do
        @rule.prerequisite.should be_nil
      end

      it "#level should equal by default(ERROR_LEVELS[:error])" do
        @rule.level.should == Rule::ERROR_LEVELS[:error]
      end
    end
  end

  context "with all parameters" do
    before(:each) do
      @new_proc = lambda {
        v1 = Validator::PresenceValidator.new("1")
        v2 = Validator::PresenceValidator.new("2")
        @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
        @validator = Validator::ComplexValidator.new(:validators => [v1, v2])
        @prerequisite = Validator::BlankValidator.new("3")
        Rule.new(["1", "2"], @message, @validator, @prerequisite, Rule::ERROR_LEVELS[:warning])
      }
    end

    it "should not raise Error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @rule = @new_proc.call
      end

      it "#target_expressions should equal by initialize" do
        @rule.target_expressions.should == ["1", "2"]
      end

      it "#message should equal by initialize" do
        @rule.message.should == @message
      end

      it "#validator should equal by initialize" do
        @rule.validator.should == @validator
      end

      it "#prerequisite should equal by initialize" do
        @rule.prerequisite.should == @prerequisite
      end

      it "#level should equal by initialize" do
        @rule.level.should == Rule::ERROR_LEVELS[:warning]
      end
    end
  end
end

describe Rule, "#check" do
  before(:each) do
    @input_spec = InputSpec.new([
                                 { :number => "1", :name => "item_1" },
                                 { :number => "2", :name => "item_2" },
                                 { :number => "3", :name => "item_3" },
                                ])
    v1 = Validator::PresenceValidator.new("1")
    v2 = Validator::PresenceValidator.new("2")
    @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
    @validator = Validator::ComplexValidator.new(:validators => [v1, v2], :logic => Validator::ComplexValidator::LOGIC_AND)
    @prerequisite = Validator::BlankValidator.new("3")
    @rule = Rule.new(["item_1", "2"], @message, @validator, @prerequisite)
  end

  context "when check rule is valid" do
    before(:each) do
      @input_spec.source = ["1", "2", ""]
      Validator::Base.values = @input_spec
    end

    it { @rule.check.should be_nil }
  end

  context "when check rule is not valid" do
    before(:each) do
      @input_spec.source = ["1", "", ""]
      Validator::Base.values = @input_spec
    end

    it { @rule.check.should_not be_nil }
    it { @rule.check.should be_a CheckResult }

    it "CheckResult#target_numbers must be only number expression" do
      result = @rule.check
      result.target_numbers.each do |number|
        @input_spec.spec_item_by_expression(number).number.should == number
      end
    end
  end

  context "when prerequisite not matched" do
    before(:each) do
      @input_spec.source = ["1", "", "3"]
      Validator::Base.values = @input_spec
    end

    it { @rule.check.should be_nil }
  end
end

describe Rule, ".add_error_level" do
  context "when new valid error level" do
    before(:each) do
      @proc = lambda {
        Rule.add_error_level(3, :fatal, "FATAL")
      }
    end

    after(:each) do
      Rule.remove_error_level(:fatal)
    end

    it "should not raise error" do
      lambda {
        @proc.call
      }.should_not raise_error
    end

    it "should 3 error levels" do
      lambda {
        @proc.call
      }.should change(Rule::ERROR_LEVELS, :size).from(2).to(3)
    end

    it "should 3 error level names" do
      lambda {
        @proc.call
      }.should change(Rule::ERROR_LEVEL_NAMES, :size).from(2).to(3)
    end
  end
end
