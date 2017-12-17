require 'spec_helper'

# Anodator::Validator::ComplexValidator
require 'anodator/validator/presence_validator'
require 'anodator/validator/complex_validator'

include Anodator::Validator

RSpec.describe ComplexValidator, '.new' do
  context 'with no paramerters' do
    it 'should not raise error' do
      expect do
        ComplexValidator.new
      end.not_to raise_error
    end
  end

  context 'with :validators only, without :logic' do
    before(:each) do
      @new_proc = lambda {
        validators = []
        validators << PresenceValidator.new('1')
        validators << PresenceValidator.new('3')
        ComplexValidator.new(validators: validators)
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    it ':logic should be ComplexValidator::LOGIC_AND' do
      complex_validator = @new_proc.call
      expect(complex_validator.options[:logic]).to be == ComplexValidator::LOGIC_AND
    end
  end

  context 'with :validators and :and_or option' do
    before(:each) do
      @new_proc = lambda {
        validators = []
        validators << PresenceValidator.new('1')
        validators << PresenceValidator.new('3')
        ComplexValidator.new(validators: validators,
                             logic: ComplexValidator::LOGIC_OR)
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    it ':logic should be ComplexValidator::LOGIC_OR' do
      complex_validator = @new_proc.call
      expect(complex_validator.options[:logic]).to be == ComplexValidator::LOGIC_OR
    end
  end
end

RSpec.describe ComplexValidator, '#valid?' do
  context 'no paramerters' do
    before(:each) do
      @validator = ComplexValidator.new
      Base.values = {
        '1' => '123',
        '2' => '',
        '3' => 'message',
        '5' => 'value'
      }
    end

    it 'should raise error ConfigurationError' do
      expect do
        @validator.valid?
      end.to raise_error ConfigurationError
    end
  end

  context 'only :validators option' do
    let(:validator) do
      validators = []
      validators << PresenceValidator.new('1')
      validators << PresenceValidator.new('3')
      ComplexValidator.new(validators: validators)
    end

    context 'for values are valid' do
      before(:each) do
        Base.values = {
          '1' => '1',
          '2' => '',
          '3' => '3'
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for values one valid, the other invalid' do
      before(:each) do
        Base.values = {
          '1' => '1',
          '2' => '',
          '3' => ''
        }
      end

      it { expect(validator).not_to be_valid }
    end

    context 'for values are invalid at all values' do
      before(:each) do
        Base.values = {
          '1' => '',
          '2' => '3',
          '3' => ''
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context ':validators and :logic OR option' do
    let(:validator) do
      validators = []
      validators << PresenceValidator.new('1')
      validators << PresenceValidator.new('3')
      ComplexValidator.new(validators: validators, logic: ComplexValidator::LOGIC_OR)
    end

    context 'for values are valid' do
      before(:each) do
        Base.values = {
          '1' => '1',
          '2' => '',
          '3' => '3'
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for values one valid, the other invalid' do
      before(:each) do
        Base.values = {
          '1' => '1',
          '2' => '',
          '3' => ''
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for values are invalid at all values' do
      before(:each) do
        Base.values = {
          '1' => '',
          '2' => '3',
          '3' => ''
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end

  context 'for nested complex validator(A && (B || C))' do
    let(:validator) do
      validators1 = []
      validators2 = []
      validators2 << PresenceValidator.new('A')
      validators1 << PresenceValidator.new('B')
      validators1 << PresenceValidator.new('C')
      validator1 = ComplexValidator.new(validators: validators1,
                                        logic: ComplexValidator::LOGIC_OR)
      validators2 << validator1
      ComplexValidator.new(validators: validators2, logic: ComplexValidator::LOGIC_AND)
    end

    context 'for A(1),  B(1), C(1)' do
      before(:each) do
        Base.values = {
          'A' => '1',
          'B' => '1',
          'C' => '1'
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for A(),  B(1), C(1)' do
      before(:each) do
        Base.values = {
          'A' => '',
          'B' => '1',
          'C' => '1'
        }
      end

      it { expect(validator).not_to be_valid }
    end

    context 'for A(),  B(), C(1)' do
      before(:each) do
        Base.values = {
          'A' => '',
          'B' => '',
          'C' => '1'
        }
      end

      it { expect(validator).not_to be_valid }
    end

    context 'for A(1),  B(), C()' do
      before(:each) do
        Base.values = {
          'A' => '1',
          'B' => '',
          'C' => ''
        }
      end

      it { expect(validator).not_to be_valid }
    end

    context 'for A(1),  B(), C(1)' do
      before(:each) do
        Base.values = {
          'A' => '1',
          'B' => '',
          'C' => '1'
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for A(1),  B(1), C()' do
      before(:each) do
        Base.values = {
          'A' => '1',
          'B' => '1',
          'C' => ''
        }
      end

      it { expect(validator).to be_valid }
    end

    context 'for A(),  B(), C()' do
      before(:each) do
        Base.values = {
          'A' => '',
          'B' => '',
          'C' => ''
        }
      end

      it { expect(validator).not_to be_valid }
    end
  end
end
