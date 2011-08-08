require "spec_helper"

# Anodator::OutputSpec
require "anodator/output_spec"

include Anodator

describe OutputSpec, ".new" do
  context "with no paramerters" do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it "#items should be empty" do
        @output_spec.items.should be_empty
      end

      it "#target should be OutputSpec::TARGET_ERROR by default" do
        @output_spec.target.should == OutputSpec::TARGET_ERROR
      end

      it "#include_no_error should be false by default" do
        @output_spec.include_no_error.should be_false
      end
    end
  end

  context "with several error items parameter" do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new([
                        :target_numbers,
                        :target_names,
                        :error_message,
                        :error_level,
                       ])
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it "#items should not be empty" do
        @output_spec.items.should_not be_empty
      end

      it "#target should be OutputSpec::TARGET_ERROR by default" do
        @output_spec.target.should == OutputSpec::TARGET_ERROR
      end

      it "#include_no_error should be false by default" do
        @output_spec.include_no_error.should be_false
      end
    end
  end

  context "with several input items parameter with error items" do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new([
                        "1",
                        "2",
                        "3",
                        "name",
                       ])
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it "#items should not be empty" do
        @output_spec.items.should_not be_empty
      end

      it "#target should be OutputSpec::TARGET_ERROR by default" do
        @output_spec.target.should == OutputSpec::TARGET_ERROR
      end

      it "#include_no_error should be false by default" do
        @output_spec.include_no_error.should be_false
      end
    end
  end

  context "with items and :target option" do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new([
                        "1",
                        "2",
                        "3",
                        "name",
                       ],
                       :target => OutputSpec::TARGET_DATA)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it "#items should not be empty" do
        @output_spec.items.should_not be_empty
      end

      it "#target should be OutputSpec::TARGET_DATA" do
        @output_spec.target.should == OutputSpec::TARGET_DATA
      end

      it "#include_no_error should be false by default" do
        @output_spec.include_no_error.should be_false
      end
    end
  end

  context "with items and :target option and :include_no_error option" do
    before(:each) do
      @new_proc = lambda {
        OutputSpec.new([
                        "1",
                        "2",
                        "3",
                        "name",
                        :target_numbers,
                        :error_message,
                        :error_level,
                       ],
                       :target => OutputSpec::TARGET_ERROR,
                       :include_no_error => true)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    context "after generated" do
      before(:each) do
        @output_spec = @new_proc.call
      end

      it "#items should not be empty" do
        @output_spec.items.should_not be_empty
      end

      it "#target should be OutputSpec::TARGET_ERROR" do
        @output_spec.target.should == OutputSpec::TARGET_ERROR
      end

      it "#include_no_error should be true" do
        @output_spec.include_no_error.should be_true
      end
    end
  end
end

describe OutputSpec, "#generate" do
  before(:each) do
    # preparation
    @input_spec = InputSpec.new([
                                 { :number => "1", :name => "first name" },
                                 { :number => "2", :name => "family name" },
                                 { :number => "3", :name => "nickname" },
                                 { :number => "4", :name => "sex" },
                                ])
    @rule_set = RuleSet.new
    @rule_set << Rule.new("1",
                          Message.new("[[1::name]] Cannot be blank"),
                          Validator::PresenceValidator.new("1"))
    @rule_set << Rule.new("2",
                          Message.new("[[2::name]] Cannot be blank"),
                          Validator::PresenceValidator.new("2"))
    @rule_set << Rule.new("3",
                          Message.new("[[3::name]] Cannot be blank"),
                          Validator::PresenceValidator.new("3"),
                          nil, Rule::LEVEL_WARNING)
    @rule_set << Rule.new(["3", "4"],
                          Message.new("[[4::name]] Must be 'M' or 'F'"),
                          Validator::InclusionValidator.new("4",
                                                            :in => %W(M F)))
    Validator::Base.values = @input_spec
  end

  context "when including errors" do
    before(:each) do
      @values = ["", "", "", ""]
      @input_spec.source = @values
      @rule_set.check_all
    end

    context "generate error list" do
      before(:each) do
        @output_spec = OutputSpec.new([
                                       "1",
                                       "2",
                                       "nickname",
                                       "4",
                                       :target_numbers,
                                       :target_names,
                                       :error_message,
                                       :error_level,
                                      ],
                                      :target => OutputSpec::TARGET_ERROR,
                                      :include_no_error => true)
      end

      it "should generate error list datas" do
        @output_spec.generate(@input_spec, @rule_set.results).should ==
          [
           ["", "", "", "", "1", "first name", "first name Cannot be blank", Rule::LEVEL_ERROR.to_s],
           ["", "", "", "", "2", "family name", "family name Cannot be blank", Rule::LEVEL_ERROR.to_s],
           ["", "", "", "", "3", "nickname", "nickname Cannot be blank", Rule::LEVEL_WARNING.to_s],
           ["", "", "", "", "3 4", "nickname sex", "sex Must be 'M' or 'F'", Rule::LEVEL_ERROR.to_s],
          ]
      end
    end

    context "generate data list" do
      before(:each) do
        @output_spec = OutputSpec.new([
                                       "1",
                                       "2",
                                       "nickname",
                                       "4",
                                       :target_numbers,
                                       :target_names,
                                       :error_message,
                                       :error_level,
                                       :error_count,
                                       :warning_count,
                                       :error_and_warning_count,
                                      ],
                                      :target => OutputSpec::TARGET_DATA,
                                      :include_no_error => true)
      end

      it "should generate list data" do
        @output_spec.generate(@input_spec, @rule_set.results).should ==
          [
           ["", "", "", "", "", "", "", "", "3", "1", "4"],
          ]
      end
    end
  end

  context "when including no errors" do
    before(:each) do
      @values = ["Tetsuhisa", "MAKINO", "makitetsu", "M"]
      @input_spec.source = @values
      @rule_set.check_all
    end

    context "generate error list include no error" do
      before(:each) do
        @output_spec = OutputSpec.new([
                                       "1",
                                       "2",
                                       "nickname",
                                       "4",
                                       :target_numbers,
                                       :target_names,
                                       :error_message,
                                       :error_level,
                                      ],
                                      :target => OutputSpec::TARGET_ERROR,
                                      :include_no_error => true)
      end

      it "should generate one data" do
        @output_spec.generate(@input_spec, @rule_set.results).should ==
          [
           ["Tetsuhisa", "MAKINO", "makitetsu", "M", "", "", "", ""]
          ]
      end
    end

    context "generate error list not include no error" do
      before(:each) do
        @output_spec = OutputSpec.new([
                                       "1",
                                       "2",
                                       "nickname",
                                       "4",
                                       :target_numbers,
                                       :target_names,
                                       :error_message,
                                       :error_level,
                                      ],
                                      :target => OutputSpec::TARGET_ERROR,
                                      :include_no_error => false)
      end

      it "should be empty" do
        @output_spec.generate(@input_spec, @rule_set.results).should be_empty
      end
    end

    context "generate data list" do
      before(:each) do
        @output_spec = OutputSpec.new([
                                       "1",
                                       "2",
                                       "nickname",
                                       "4",
                                       :target_numbers,
                                       :target_names,
                                       :error_message,
                                       :error_level,
                                       :error_count,
                                       :warning_count,
                                       :error_and_warning_count,
                                      ],
                                      :target => OutputSpec::TARGET_DATA,
                                      :include_no_error => true)
      end

      it "should not raise error" do
        @output_spec.generate(@input_spec, @rule_set.results).should ==
          [
           ["Tetsuhisa", "MAKINO", "makitetsu", "M", "", "", "", "", "0", "0", "0"],
          ]
      end
    end
  end
end
