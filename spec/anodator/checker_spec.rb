require "spec_helper"

# Anodator::Checker
require "anodator/checker"

include Anodator
include Anodator::Validator

RSpec.describe Checker, ".new" do
  before(:each) do
    @input_spec = InputSpec.new([
                                 { :number => "0", :name => "ID" },
                                 { :number => "1", :name => "First name" },
                                 { :number => "2", :name => "Family name" },
                                 { :number => "3", :name => "Birthday" },
                                 { :number => "4", :name => "Sex" },
                                 { :number => "5", :name => "Phone number" },
                                 { :number => "6", :name => "ZIP" },
                                ])
    @rule_set = RuleSet.new
    # First name
    validator =
      ComplexValidator.new(:validators => [LengthValidator.new("1", :in => 3..25),
                                           FormatValidator.new("1", :format => /^[a-z]+$/i)])
    @rule_set << Rule.new("First name",
                          Message.new("[[1::name]] is invalid."),
                          validator)
    # Family name
    validator =
      ComplexValidator.new(:validators => [LengthValidator.new("2", :in => 3..25),
                                           FormatValidator.new("2", :format => /^[a-z]+$/i)])
    @rule_set << Rule.new("Family name",
                          Message.new("[[2::name]] is invalid."),
                          validator)
    # Birthday
    @rule_set << Rule.new("Birthday",
                          Message.new("[[3::name]] is invalid."),
                          FormatValidator.new("3", :format => /^\d{4}-\d{2}-\d{2}$/))
    # Sex
    @rule_set << Rule.new("Sex",
                          Message.new("[[4::name]] is invalid."),
                          InclusionValidator.new("4", :in => %W(M F)))
    # Phone number
    @rule_set << Rule.new("Phone number",
                          Message.new("[[5::name]] is invalid."),
                          FormatValidator.new("5", :format => /^\d+-\d+-\d$/, :allow_blank => true))
    # ZIP
    @rule_set << Rule.new("ZIP",
                          Message.new("[[6::name]] is invalid."),
                          FormatValidator.new("6", :format => /^\d{3}-\d{4}$/, :allow_blank => true))
    @error_list_output_spec = OutputSpec.new([
                                              "ID",
                                              :error_level,
                                              :target_numbers,
                                              :error_message,
                                             ],
                                             :target => OutputSpec::TARGET_ERROR,
                                             :include_no_error => true)
    @error_report_output_spec = OutputSpec.new([
                                                "ID",
                                                :error_count,
                                                :warning_count,
                                                :error_and_warning_count,
                                               ],
                                               :target => OutputSpec::TARGET_DATA)
    @valid_values = %W(1 Tetsuhisa MAKINO 1980-01-25 M 1-2-3 123-3456)
    @invalid_values = ["1", "te", "ma", "1980/01/25", "C", "000000000000", "1234-567"]
  end

  context "with no parameter" do
    it "should raise ArgumentError" do
      expect {
        Checker.new
      }.to raise_error ArgumentError
    end
  end

  context "with only input_spec" do
    it "should raise ArgumentError" do
      expect {
        Checker.new(@input_spec)
      }.to raise_error ArgumentError
    end
  end

  context "with input_spec and rule_set" do
    it "should raise ArgumentError" do
      expect {
        Checker.new(@input_spec, @rule_set)
      }.to raise_error ArgumentError
    end
  end

  context "with input_spec, rule_set and default_output_spec" do
    it "should not raise error" do
      expect {
        Checker.new(@input_spec, @rule_set, @error_list_output_spec)
      }.not_to raise_error
    end
  end
end

RSpec.describe "on after creation" do
  before(:each) do
    @input_spec = InputSpec.new([
                                 { :number => "0", :name => "ID" },
                                 { :number => "1", :name => "First name" },
                                 { :number => "2", :name => "Family name" },
                                 { :number => "3", :name => "Birthday" },
                                 { :number => "4", :name => "Sex" },
                                 { :number => "5", :name => "Phone number" },
                                 { :number => "6", :name => "ZIP" },
                                ])
    @rule_set = RuleSet.new
    # First name
    validator =
      ComplexValidator.new(:validators => [LengthValidator.new("1", :in => 3..25),
                                           FormatValidator.new("1", :format => /^[a-z]+$/i)])
    @rule_set << Rule.new("First name",
                          Message.new("[[1::name]] is invalid."),
                          validator)
    # Family name
    validator =
      ComplexValidator.new(:validators => [LengthValidator.new("2", :in => 3..25),
                                           FormatValidator.new("2", :format => /^[a-z]+$/i)])
    @rule_set << Rule.new("Family name",
                          Message.new("[[2::name]] is invalid."),
                          validator)
    # Birthday
    @rule_set << Rule.new("Birthday",
                          Message.new("[[3::name]] is invalid."),
                          FormatValidator.new("3", :format => /^\d{4}-\d{2}-\d{2}$/))
    # Sex
    @rule_set << Rule.new("Sex",
                          Message.new("[[4::name]] is invalid."),
                          InclusionValidator.new("4", :in => %W(M F)))
    # Phone number
    @rule_set << Rule.new("Phone number",
                          Message.new("[[5::name]] is invalid."),
                          FormatValidator.new("5", :format => /^\d+-\d+-\d$/, :allow_blank => true))
    # ZIP
    @rule_set << Rule.new("ZIP",
                          Message.new("[[6::name]] is invalid."),
                          FormatValidator.new("6", :format => /^\d{3}-\d{4}$/, :allow_blank => true))
    @error_list_output_spec = OutputSpec.new([
                                              "ID",
                                              :error_level,
                                              :target_numbers,
                                              :error_message,
                                             ],
                                             :target => OutputSpec::TARGET_ERROR,
                                             :include_no_error => true)
    @error_report_output_spec = OutputSpec.new([
                                                "ID",
                                                :error_count,
                                                :warning_count,
                                                :error_and_warning_count,
                                               ],
                                               :target => OutputSpec::TARGET_DATA)
    @valid_values = %W(1 Tetsuhisa MAKINO 1980-01-25 M 1-2-3 123-3456)
    @invalid_values = ["1", "te", "ma", "1980/01/25", "C", "000000000000", "1234-567"]

    @checker = Checker.new(@input_spec, @rule_set, @error_list_output_spec)
  end

  describe "#add_output_spec" do
    before(:each) do
      @proc = lambda {
        @checker.add_output_spec(@error_report_output_spec)
      }
    end

    it "should not raise error" do
      expect(@proc).not_to raise_error
    end

    context "after process" do
      before(:each) do
        @proc.call
      end

      it "should have 2 output_specs" do
        expect(@checker.instance_eval("@output_specs.size")).to be == 2
      end
    end
  end

  describe "#run" do
    before(:each) do
      @checker.add_output_spec(@error_report_output_spec)
    end

    context "with valid values" do
      before(:each) do
        @proc = lambda {
          @checker.run(@valid_values)
        }
      end

      it { expect(@proc).not_to raise_error }

      it "should return 2 outputs" do
        expect(@proc.call.size).to be == 2
      end
    end

    context "with invalid values" do
      before(:each) do
        @proc = lambda {
          @checker.run(@invalid_values)
        }
      end

      it { expect(@proc).not_to raise_error }

      it "should return 2 outputs" do
        expect(@proc.call.size).to be == 2
      end
    end
  end

  describe "#validate_configuration" do
    context "when include invalid rule" do
      before(:each) do
        @rule_set << Rule.new("Unknown",
                              Message.new("message"),
                              FormatValidator.new("3", :format => //))
      end

      it "should raise InvalidConfiguration" do
        expect {
          Checker.new(@input_spec,
                      @rule_set,
                      @error_list_output_spec, true)
        }.to raise_error InvalidConfiguration
      end
    end

    context "when include invalid output spec" do
      before(:each) do
        @invalid_output_spec = OutputSpec.new(["Unknown"])
      end

      it "should raise InvalidConfiguration" do
        expect {
          Checker.new(@input_spec,
                      @rule_set,
                      @invalid_output_spec, true)
        }.to raise_error InvalidConfiguration
      end
    end
  end

  describe "#rule_info" do
    before(:each) do
      @checker.add_output_spec(@error_report_output_spec)
    end

    context "with valid values" do
      before(:each) do
        @proc = lambda {
          @checker.rule_info
        }
      end

      it { expect(@proc).not_to raise_error }

      it "should return 2 outputs" do
        expect(@proc.call).to be_a String
      end
    end
  end
end
