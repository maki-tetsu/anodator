require 'spec_helper'

# Anodator::Rule
require 'anodator/rule'

include Anodator

RSpec.describe Rule, '#new' do
  context 'with no parameters' do
    it 'should raise ArgumentError' do
      expect do
        Rule.new
      end.to raise_error ArgumentError
    end
  end

  context 'with only target_expressions' do
    it 'should raise ArgumentError' do
      expect do
        Rule.new(%w[1 2 3])
      end.to raise_error ArgumentError
    end
  end

  context 'with target_expressions and message' do
    it 'should raise ArgumentError' do
      expect do
        Rule.new(%w[1 2 3],
                 Message.new("'[[1::name]]' cannot be blank"))
      end.to raise_error ArgumentError
    end
  end

  context 'with target_expressions, message and validator' do
    before(:each) do
      @new_proc = lambda {
        v1 = Validator::PresenceValidator.new('1')
        v2 = Validator::PresenceValidator.new('2')
        @validator = Validator::ComplexValidator.new(validators: [v1, v2])
        @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
        Rule.new(%w[1 2], @message, @validator)
      }
    end

    it 'should not raise Error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @rule = @new_proc.call
      end

      it '#target_expressions should equal by initialize' do
        expect(@rule.target_expressions).to be == %w[1 2]
      end

      it '#message should equal by initialize' do
        expect(@rule.message).to be == @message
      end

      it '#validator should equal by initialize' do
        expect(@rule.validator).to be == @validator
      end

      it '#prerequisite should be nil' do
        expect(@rule.prerequisite).to be_nil
      end

      it '#level should equal by default(ERROR_LEVELS[:error])' do
        expect(@rule.level).to be == Rule::ERROR_LEVELS[:error]
      end
    end
  end

  context 'with all parameters' do
    before(:each) do
      @new_proc = lambda {
        v1 = Validator::PresenceValidator.new('1')
        v2 = Validator::PresenceValidator.new('2')
        @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
        @validator = Validator::ComplexValidator.new(validators: [v1, v2])
        @prerequisite = Validator::BlankValidator.new('3')
        Rule.new(%w[1 2], @message, @validator, @prerequisite, Rule::ERROR_LEVELS[:warning])
      }
    end

    it 'should not raise Error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @rule = @new_proc.call
      end

      it '#target_expressions should equal by initialize' do
        expect(@rule.target_expressions).to be == %w[1 2]
      end

      it '#message should equal by initialize' do
        expect(@rule.message).to be == @message
      end

      it '#validator should equal by initialize' do
        expect(@rule.validator).to be == @validator
      end

      it '#prerequisite should equal by initialize' do
        expect(@rule.prerequisite).to be == @prerequisite
      end

      it '#level should equal by initialize' do
        expect(@rule.level).to be == Rule::ERROR_LEVELS[:warning]
      end
    end
  end

  context 'with multiple prerequisite' do
    before(:each) do
      @new_proc = lambda {
        v1 = Validator::PresenceValidator.new('1')
        v2 = Validator::PresenceValidator.new('2')
        @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
        @validator = Validator::ComplexValidator.new(validators: [v1, v2])
        @prerequisites = [
          Validator::BlankValidator.new('3'),
          Validator::BlankValidator.new('4')
        ]

        Rule.new(%w[1 2], @message, @validator, @prerequisites, Rule::ERROR_LEVELS[:warning])
      }
    end

    it 'should not raise Error' do
      expect(@new_proc).not_to raise_error
    end
  end
end

RSpec.describe Rule, '#check' do
  before(:each) do
    @input_spec = InputSpec.new([
                                  { number: '1', name: 'item_1' },
                                  { number: '2', name: 'item_2' },
                                  { number: '3', name: 'item_3' }
                                ])
    v1 = Validator::PresenceValidator.new('1')
    v2 = Validator::PresenceValidator.new('2')
    @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
    @validator = Validator::ComplexValidator.new(validators: [v1, v2], logic: Validator::ComplexValidator::LOGIC_AND)
    @prerequisite = Validator::BlankValidator.new('3')
    @rule = Rule.new(%w[item_1 2], @message, @validator, @prerequisite)
  end

  context 'when check rule is valid' do
    before(:each) do
      @input_spec.source = ['1', '2', '']
      Validator::Base.values = @input_spec
    end

    it { expect(@rule.check).to be_nil }
  end

  context 'when check rule is not valid' do
    before(:each) do
      @input_spec.source = ['1', '', '']
      Validator::Base.values = @input_spec
    end

    it { expect(@rule.check).not_to be_nil }
    it { expect(@rule.check).to be_a CheckResult }

    it 'CheckResult#target_numbers must be only number expression' do
      result = @rule.check
      result.target_numbers.each do |number|
        expect(@input_spec.spec_item_by_expression(number).number).to be == number
      end
    end
  end

  context 'when prerequisite not matched' do
    before(:each) do
      @input_spec.source = ['1', '', '3']
      Validator::Base.values = @input_spec
    end

    it { expect(@rule.check).to be_nil }
  end

  context 'with complex prerequisite' do
    before(:each) do
      @input_spec = InputSpec.new([
                                    { number: '1', name: 'item_1' },
                                    { number: '2', name: 'item_2' },
                                    { number: '3', name: 'item_3' },
                                    { number: '4', name: 'item_4' }
                                  ])
      v1 = Validator::PresenceValidator.new('1')
      v2 = Validator::PresenceValidator.new('2')
      @message = Message.new("'[[1::name]]' and '[[2::name]]' cannot be blank")
      @validator = Validator::ComplexValidator.new(validators: [v1, v2], logic: Validator::ComplexValidator::LOGIC_AND)
      @prerequisites = [
        Validator::BlankValidator.new('3'),
        Validator::BlankValidator.new('4')
      ]
      @rule = Rule.new(%w[item_1 2], @message, @validator, @prerequisites)
    end

    context 'when prerequisites matches and invalid' do
      before(:each) do
        @input_spec.source = ['1', '', '', '']
        Validator::Base.values = @input_spec
      end

      it { expect(@rule.check).to be_a CheckResult }
    end

    context 'when prerequisites matches and valid' do
      before(:each) do
        @input_spec.source = ['1', '2', '', '']
        Validator::Base.values = @input_spec
      end

      it { expect(@rule.check).to be_nil }
    end

    context 'when prerequisites not matches and valid' do
      before(:each) do
        @input_spec.source = ['1', '2', '', '4']
        Validator::Base.values = @input_spec
      end

      it { expect(@rule.check).to be_nil }
    end

    context 'when prerequisites not matches and invalid' do
      before(:each) do
        @input_spec.source = ['1', '2', '', '4']
        Validator::Base.values = @input_spec
      end

      it { expect(@rule.check).to be_nil }
    end
  end
end

RSpec.describe Rule, '.add_error_level' do
  context 'when new valid error level' do
    before(:each) do
      @proc = lambda {
        Rule.add_error_level(3, :fatal, 'FATAL')
      }
    end

    after(:each) do
      Rule.remove_error_level(:fatal)
    end

    it 'should not raise error' do
      expect do
        @proc.call
      end.not_to raise_error
    end

    it 'should 3 error levels' do
      expect do
        @proc.call
      end.to change(Rule::ERROR_LEVELS, :size).from(2).to(3)
    end

    it 'should 3 error level names' do
      expect do
        @proc.call
      end.to change(Rule::ERROR_LEVEL_NAMES, :size).from(2).to(3)
    end
  end
end
