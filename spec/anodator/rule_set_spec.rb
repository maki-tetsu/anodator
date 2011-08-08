require "spec_helper"

# Anodator::RuleSet
require "anodator/rule_set"

include Anodator

describe RuleSet, ".new" do
  context "with no parameters" do
    it "should not raise error" do
      lambda {
        RuleSet.new
      }.should_not raise_error
    end
  end
end

describe RuleSet, "after generated" do
  before(:each) do
    # preparation
    @input_spec = InputSpec.new([
                                 { :number => "1", :name => "first name"},
                                 { :number => "2", :name => "family name"},
                                 { :number => "3", :name => "phone"},
                                 { :number => "4", :name => "mail address"},
                                 { :number => "5", :name => "sex"},
                                 { :number => "6", :name => "age"},
                                ])
    @records =
      [
       [ "Tetsuhisa" , ""         , "0000-0000-0000"  , "tim.makino@gmail.com" , "M"    , "31" ],
       [ "Takashi"   , "Nakajima" , "0000-00-00-0001" , "nakajima@example@com" , "Male" , "28.4" ],
      ]

    ### Rules
    @rule_set = RuleSet.new

    ### set datas
    Validator::Base.values = @input_spec
  end

  describe RuleSet, "#add_rule" do
    before(:each) do
      # first name
      @rule_set.add_rule(Rule.new("1",
                                  Message.new("[[1::name]] cannot be blank."),
                                  Validator::PresenceValidator.new("1")))
      # family name
      @rule_set.add_rule(Rule.new("2",
                                  Message.new("[[2::name]] cannot be blank."),
                                  Validator::PresenceValidator.new("2")))
      # phone
      @rule_set.add_rule(Rule.new("phone",
                                  Message.new("[[phone::name]] is invalid format."),
                                  Validator::FormatValidator.new("phone", :format => /^\d+-\d+-\d+$/),
                                  Validator::PresenceValidator.new("phone"), Rule::LEVEL_WARNING))
      # mail address
      @rule_set.add_rule(Rule.new("4",
                                  Message.new("[[4:name]] is invalid format."),
                                  Validator::FormatValidator.new("4", :format => /^[^@]+@[^@]+$/, :allow_blank => true)))
      # sex
      @rule_set.add_rule(Rule.new("5",
                                  Message.new("[[5::name]] must be M/F/Man/Woman."),
                                  Validator::InclusionValidator.new("5", :in => %W(M F Man Woman))))
      # age
      @rule_set.add_rule(Rule.new("age",
                                  Message.new("[[age::name]] must be integer."),
                                  Validator::NumericValidator.new("age", :only_integer => true)))
    end

    it "should have all rules" do
      @rule_set.instance_eval("@rules.count").should == 6
    end
  end

  describe RuleSet, "#<<" do
    before(:each) do
      # first name
      @rule_set << Rule.new("1",
                            Message.new("[[1::name]] cannot be blank."),
                            Validator::PresenceValidator.new("1"))
      # family name
      @rule_set << Rule.new("2",
                            Message.new("[[2::name]] cannot be blank."),
                            Validator::PresenceValidator.new("2"))
      # phone
      @rule_set << Rule.new("phone",
                            Message.new("[[phone::name]] is invalid format."),
                            Validator::FormatValidator.new("phone", :format => /^\d+-\d+-\d+$/),
                            Validator::PresenceValidator.new("phone"), Rule::LEVEL_WARNING)
      # mail address
      @rule_set << Rule.new("4",
                            Message.new("[[4::name]] is invalid format."),
                            Validator::FormatValidator.new("4", :format => /^[^@]+@[^@]+$/, :allow_blank => true))
      # sex
      @rule_set << Rule.new("5",
                            Message.new("[[5::name]] must be M/F/Man/Woman."),
                            Validator::InclusionValidator.new("5", :in => %W(M F Man Woman)))
      # age
      @rule_set << Rule.new("age",
                            Message.new("[[age::name]] must be integer."),
                            Validator::NumericValidator.new("age", :only_integer => true))
    end

    it "should have all rules" do
      @rule_set.instance_eval("@rules.count").should == 6
    end
  end

  describe RuleSet, "#check_all" do
    before(:each) do
      # first name
      @rule_set << Rule.new("1",
                            Message.new("[[1::name]] cannot be blank."),
                            Validator::PresenceValidator.new("1"))
      # family name
      @rule_set << Rule.new("2",
                            Message.new("[[2::name]] cannot be blank."),
                            Validator::PresenceValidator.new("2"))
      # phone
      @rule_set << Rule.new("phone",
                            Message.new("[[phone::name]] is invalid format."),
                            Validator::FormatValidator.new("phone", :format => /^\d+-\d+-\d+$/),
                            Validator::PresenceValidator.new("phone"), Rule::LEVEL_WARNING)
      # mail address
      @rule_set << Rule.new("4",
                            Message.new("[[4::name]] is invalid format."),
                            Validator::FormatValidator.new("4", :format => /^[^@]+@[^@]+$/, :allow_blank => true))
      # sex
      @rule_set << Rule.new("5",
                            Message.new("[[5::name]] must be M/F/Man/Woman."),
                            Validator::InclusionValidator.new("5", :in => %W(M F Man Woman)))
      # age
      @rule_set << Rule.new("age",
                            Message.new("[[age::name]] must be integer."),
                            Validator::NumericValidator.new("age", :only_integer => true))

      @proc = lambda {
        @input_spec.source = @records.first
        @rule_set.check_all
      }
    end

    it "should not raise error" do
      @proc.should_not raise_error
    end

    it "should have results" do
      @proc.call
      @rule_set.instance_eval("@results.count").should_not be_zero
    end
  end

  describe RuleSet, "#results" do
    before(:each) do
      # first name
      @rule_set << Rule.new("1",
                            Message.new("[[1::name]] cannot be blank."),
                            Validator::PresenceValidator.new("1"))
      # family name
      @rule_set << Rule.new("2",
                            Message.new("[[2::name]] cannot be blank."),
                            Validator::PresenceValidator.new("2"))
      # phone
      @rule_set << Rule.new("phone",
                            Message.new("[[phone::name]] is invalid format.([[phone::value]])"),
                            Validator::FormatValidator.new("phone", :format => /^\d+-\d+-\d+$/),
                            Validator::PresenceValidator.new("phone"), Rule::LEVEL_WARNING)
      # mail address
      @rule_set << Rule.new("4",
                            Message.new("[[4::name]] is invalid format.([[4::value]])"),
                            Validator::FormatValidator.new("4", :format => /^[^@]+@[^@]+$/, :allow_blank => true))
      # sex
      @rule_set << Rule.new("5",
                            Message.new("[[5::name]] must be M/F/Man/Woman.([[5::value]])"),
                            Validator::InclusionValidator.new("5", :in => %W(M F Man Woman)))
      # age
      @rule_set << Rule.new("age",
                            Message.new("[[age::name]] must be integer.([[age::value]])"),
                            Validator::NumericValidator.new("age", :only_integer => true))

      @input_spec.source = @records.last
      @rule_set.check_all
    end

    it "should have results count 4" do
      @rule_set.results.count.should == 4
    end
  end
end
