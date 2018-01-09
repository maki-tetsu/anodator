require 'spec_helper'

# Anodator::OutputSpec
require 'anodator/output_spec'

include Anodator

RSpec.describe OutputSpec, '.new' do
  context 'with no paramerters' do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it '#items should be empty' do
        expect(@output_spec.items).to be_empty
      end

      it '#target should be OutputSpec::TARGETS[:ERROR] by default' do
        expect(@output_spec.target).to be == OutputSpec::TARGETS[:ERROR]
      end

      it '#include_no_error should be false by default' do
        expect(@output_spec.include_no_error).to be_falsey
      end
    end
  end

  context 'with several error items parameter' do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new(%i[
                         target_numbers
                         target_names
                         target_values
                         error_message
                         error_level
                       ])
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it '#items should not be empty' do
        expect(@output_spec.items).not_to be_empty
      end

      it '#target should be OutputSpec::TARGETS[:ERROR] by default' do
        expect(@output_spec.target).to be == OutputSpec::TARGETS[:ERROR]
      end

      it '#include_no_error should be false by default' do
        expect(@output_spec.include_no_error).to be_falsey
      end
    end
  end

  context 'with several input items parameter with error items' do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new(%w[
                         1
                         2
                         3
                         name
                       ])
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it '#items should not be empty' do
        expect(@output_spec.items).not_to be_empty
      end

      it '#target should be OutputSpec::TARGETS[:ERROR] by default' do
        expect(@output_spec.target).to be == OutputSpec::TARGETS[:ERROR]
      end

      it '#include_no_error should be false by default' do
        expect(@output_spec.include_no_error).to be_falsey
      end
    end
  end

  context 'with items and :target option' do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new(%w[
                         1
                         2
                         3
                         name
                       ],
                       target: OutputSpec::TARGETS[:DATA])
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it '#items should not be empty' do
        expect(@output_spec.items).not_to be_empty
      end

      it '#target should be OutputSpec::TARGETS[:DATA]' do
        expect(@output_spec.target).to be == OutputSpec::TARGETS[:DATA]
      end

      it '#include_no_error should be false by default' do
        expect(@output_spec.include_no_error).to be_falsey
      end
    end
  end

  context 'with items and :target option and :include_no_error option' do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new([
                         '1',
                         '2',
                         '3',
                         'name',
                         :target_numbers,
                         :error_message,
                         :error_level
                       ],
                       target: OutputSpec::TARGETS[:ERROR],
                       include_no_error: true)
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    context 'after generated' do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it '#items should not be empty' do
        expect(@output_spec.items).not_to be_empty
      end

      it '#target should be OutputSpec::TARGETS[:ERROR]' do
        expect(@output_spec.target).to be == OutputSpec::TARGETS[:ERROR]
      end

      it '#include_no_error should be true' do
        expect(@output_spec.include_no_error).to be_truthy
      end
    end
  end
end

RSpec.describe OutputSpec, '#generate' do
  before(:each) do
    # preparation
    @input_spec = InputSpec.new([
                                  { number: '1', name: 'first name' },
                                  { number: '2', name: 'family name' },
                                  { number: '3', name: 'nickname' },
                                  { number: '4', name: 'sex' }
                                ])
    @rule_set = RuleSet.new
    @rule_set << Rule.new('1',
                          Message.new('[[1::name]] Cannot be blank'),
                          Validator::PresenceValidator.new('1'))
    @rule_set << Rule.new('2',
                          Message.new('[[2::name]] Cannot be blank'),
                          Validator::PresenceValidator.new('2'))
    @rule_set << Rule.new('3',
                          Message.new('[[3::name]] Cannot be blank'),
                          Validator::PresenceValidator.new('3'),
                          nil, Rule::ERROR_LEVELS[:warning])
    @rule_set << Rule.new(%w[3 4],
                          Message.new("[[4::name]] Must be 'M' or 'F'"),
                          Validator::InclusionValidator.new('4',
                                                            in: %w[M F]))
    Validator::Base.values = @input_spec
  end

  context 'when including errors' do
    before(:each) do
      @values = ['', '', '', '']
      @input_spec.source = @values
      @rule_set.check_all
    end

    context 'generate error list' do
      before(:each) do
        @output_spec = OutputSpec.new([
                                        '1',
                                        '2',
                                        'nickname',
                                        '4',
                                        :target_numbers,
                                        :target_names,
                                        :error_message,
                                        :error_level
                                      ],
                                      target: OutputSpec::TARGETS[:ERROR],
                                      include_no_error: true)
      end

      it 'should generate error list datas' do
        expect(@output_spec.generate(@input_spec, @rule_set.results)).to be ==
                                                                         [
                                                                           ['', '', '', '', '1', 'first name', 'first name Cannot be blank', Rule::ERROR_LEVELS[:error].to_s],
                                                                           ['', '', '', '', '2', 'family name', 'family name Cannot be blank', Rule::ERROR_LEVELS[:error].to_s],
                                                                           ['', '', '', '', '3', 'nickname', 'nickname Cannot be blank', Rule::ERROR_LEVELS[:warning].to_s],
                                                                           ['', '', '', '', '3 4', 'nickname sex', "sex Must be 'M' or 'F'", Rule::ERROR_LEVELS[:error].to_s]
                                                                         ]
      end
    end

    context 'generate data list' do
      before(:each) do
        @output_spec = OutputSpec.new([
                                        '1',
                                        '2',
                                        'nickname',
                                        '4',
                                        :target_numbers,
                                        :target_names,
                                        :error_message,
                                        :error_level,
                                        :error_count,
                                        :warning_count,
                                        :error_and_warning_count
                                      ],
                                      target: OutputSpec::TARGETS[:DATA],
                                      include_no_error: true)
      end

      it 'should generate list data' do
        expect(@output_spec.generate(@input_spec, @rule_set.results)).to be ==
                                                                         [
                                                                           ['', '', '', '', '', '', '', '', '3', '1', '4']
                                                                         ]
      end
    end
  end

  context 'when including no errors' do
    before(:each) do
      @values = %w[Tetsuhisa MAKINO makitetsu M]
      @input_spec.source = @values
      @rule_set.check_all
    end

    context 'generate error list include no error' do
      before(:each) do
        @output_spec = OutputSpec.new([
                                        '1',
                                        '2',
                                        'nickname',
                                        '4',
                                        :target_numbers,
                                        :target_names,
                                        :error_message,
                                        :error_level
                                      ],
                                      target: OutputSpec::TARGETS[:ERROR],
                                      include_no_error: true)
      end

      it 'should generate one data' do
        expect(@output_spec.generate(@input_spec, @rule_set.results)).to be ==
                                                                         [
                                                                           ['Tetsuhisa', 'MAKINO', 'makitetsu', 'M', '', '', '', '']
                                                                         ]
      end
    end

    context 'generate error list not include no error' do
      before(:each) do
        @output_spec = OutputSpec.new([
                                        '1',
                                        '2',
                                        'nickname',
                                        '4',
                                        :target_numbers,
                                        :target_names,
                                        :error_message,
                                        :error_level
                                      ],
                                      target: OutputSpec::TARGETS[:ERROR],
                                      include_no_error: false)
      end

      it 'should be empty' do
        expect(@output_spec.generate(@input_spec, @rule_set.results)).to be_empty
      end
    end

    context 'generate data list' do
      before(:each) do
        @output_spec = OutputSpec.new([
                                        '1',
                                        '2',
                                        'nickname',
                                        '4',
                                        :target_numbers,
                                        :target_names,
                                        :error_message,
                                        :error_level,
                                        :error_count,
                                        :warning_count,
                                        :error_and_warning_count
                                      ],
                                      target: OutputSpec::TARGETS[:DATA],
                                      include_no_error: true)
      end

      it 'should not raise error' do
        expect(@output_spec.generate(@input_spec, @rule_set.results)).to be ==
                                                                         [
                                                                           ['Tetsuhisa', 'MAKINO', 'makitetsu', 'M', '', '', '', '', '0', '0', '0']
                                                                         ]
      end
    end
  end
end
