require "spec_helper"

# Anodator::Validator
require "anodator/validator"

describe "require validators" do
  it { Anodator::Validator::Base.should_not be_nil }
  it { Anodator::Validator::BlankValidator.should_not be_nil }
  it { Anodator::Validator::ComplexValidator.should_not be_nil }
  it { Anodator::Validator::FormatValidator.should_not be_nil }
  it { Anodator::Validator::InclusionValidator.should_not be_nil }
  it { Anodator::Validator::LengthValidator.should_not be_nil }
  it { Anodator::Validator::NumericValidator.should_not be_nil }
  it { Anodator::Validator::PresenceValidator.should_not be_nil }
end

