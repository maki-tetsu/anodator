require 'spec_helper'

# Anodator::Validator
require 'anodator/validator'

RSpec.describe 'require validators' do
  it { expect(Anodator::Validator::Base).not_to be_nil }
  it { expect(Anodator::Validator::BlankValidator).not_to be_nil }
  it { expect(Anodator::Validator::ComplexValidator).not_to be_nil }
  it { expect(Anodator::Validator::FormatValidator).not_to be_nil }
  it { expect(Anodator::Validator::InclusionValidator).not_to be_nil }
  it { expect(Anodator::Validator::LengthValidator).not_to be_nil }
  it { expect(Anodator::Validator::NumericValidator).not_to be_nil }
  it { expect(Anodator::Validator::PresenceValidator).not_to be_nil }
end
