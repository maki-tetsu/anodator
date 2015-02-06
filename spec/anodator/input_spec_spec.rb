require "spec_helper"

# Anodator::InputSpec
require "anodator/input_spec"

include Anodator

describe InputSpec, ".new" do
  context "with no parameters" do
    it "should not raise error" do
      lambda {
        InputSpec.new
      }.should_not raise_error
    end

    it "@spec_items.count should be zero" do
      input_spec = InputSpec.new
      input_spec.instance_eval("@spec_items.count").should be_zero
    end
  end

  context "with several items parameter" do
    before(:all) do
      @new_proc = lambda {
        InputSpec.new([
                       { :number => "1", :name => "item_1" },
                       { :number => "2", :name => "item_2" },
                       { :number => "3", :name => "item_3" },
                       { :number => "4", :name => "item_4" },
                       { :number => "5", :name => "item_5", :type => InputSpecItem::TYPE_NUMERIC },
                       { :number => "6", :name => "item_6" },
                       { :number => "7", :name => "item_7" },
                       { :number => "8", :name => "item_8" },
                       { :number => "9", :name => "item_9" },
                      ])
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "@spec_items.count should be 9" do
      input_spec = @new_proc.call
      input_spec.instance_eval("@spec_items.count").should == 9
    end

    it "@spec_items.each type.should be STRING" do
      input_spec = @new_proc.call
      input_spec.instance_eval("@spec_items").each do |input_spec_item|
        if input_spec_item.number == "5"
          input_spec_item.type.should == InputSpecItem::TYPE_NUMERIC
        else
          input_spec_item.type.should == InputSpecItem::TYPE_STRING
        end
      end
    end
  end
end

describe InputSpec, "after generated" do
  before(:each) do
    @input_spec = InputSpec.new([
                                 { :number => "1", :name => "item_1" },
                                 { :number => "2", :name => "item_2" },
                                 { :number => "3", :name => "item_3" },
                                 { :number => "4", :name => "item_4" },
                                 { :number => "5", :name => "item_5", :type => InputSpecItem::TYPE_NUMERIC },
                                 { :number => "6", :name => "item_6", :type => InputSpecItem::TYPE_NUMERIC },
                                 { :number => "7", :name => "item_7" },
                                 { :number => "8", :name => "item_8" },
                                 { :number => "9", :name => "item_9" },
                                ])
  end

  describe "#source=" do
    context "with valid array values" do
      before(:each) do
        @values = %W(1 2 3 4 5 6 7 8 9)
        @proc = lambda {
          @input_spec.source = @values
        }
      end

      it "should not raise error" do
        @proc.should_not raise_error
      end

      it "@source should equal presented values" do
        @proc.should change { @input_spec.instance_eval("@source") }.
          from(nil).to(@values)
      end
    end

    context "with invalid fixnum value" do
      it "should raise ArgumentError" do
        lambda {
          @input_spec.source = nil
        }.should raise_error ArgumentError
      end
    end
  end

  describe "#clear_source" do
    before(:each) do
      @values = %W(1 2 3 4 5 6 7 8 9)
      @input_spec.source = @values
      @proc = lambda {
        @input_spec.clear_source
      }
    end

    it "@source should change to nil" do
      @proc.should change { @input_spec.instance_eval("@source") }.
        from(@values).to(nil)
    end
  end

  describe "#[]" do
    context "when initialized source" do
      before(:each) do
        @values = %W(1 2 3 4 5 6 7 8 9)
        @input_spec.source = @values
      end

      context "when access existing index" do
        before(:each) do
          @proc = lambda {
            @input_spec[3]
          }
        end

        it "should get value" do
          @proc.call.should == @values[3]
        end
      end

      context "when access non-existing index" do
        before(:each) do
          @proc = lambda {
            @input_spec[@values.size]
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end

      context "when access existing number" do
        before(:each) do
          @proc = lambda {
            @input_spec["7"]
          }
        end

        it "should get value" do
          @proc.call.should == @values[6]
        end
      end

      context "when access non-existing number" do
        before(:each) do
          @proc = lambda {
            @input_spec[(@values.size + 1).to_s]
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end

      context "when access existing name" do
        before(:each) do
          @proc = lambda {
            @input_spec["item_2"]
          }
        end

        it "should get value" do
          @proc.call.should == @values[1]
        end
      end

      context "when access non-existing name" do
        before(:each) do
          @proc = lambda {
            @input_spec["unknown"]
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end

      context "when access valid calculation expression" do
        before(:each) do
          @proc = lambda {
            @input_spec["CALC::[[1]]+[[2]]"]
          }
        end

        it "should not raise error" do
          @proc.should_not raise_error
        end

        it { @proc.call.should == "12" }
      end

      context "when access invalid calculation expression with unknown number" do
        before(:each) do
          @proc = lambda {
            @input_spec["CALC::[[1]]+[[12]]"]
          }
        end

        it "should raise UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end

      context "when access invalid calculation expression with syntax error" do
        before(:each) do
          @proc = lambda {
            @input_spec["CALC::[[1]][[2]]"]
          }
        end

        it "should raise error" do
          @proc.should_not raise_error
        end
      end

      context "when access valid calculation expression for numeric add" do
        before(:each) do
          @proc = lambda {
            @input_spec["CALC::[[5]]+[[6]]"]
          }
        end

        it "should not raise error" do
          @proc.should_not raise_error
        end

        it { @proc.call.should == "11.0" }
      end

      context "when access invalid calculation expression for numeric and string add" do
        before(:each) do
          @proc = lambda {
            @input_spec["CALC::[[1]]+[[6]]"]
          }
        end

        it "should raise UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end
    end

    context "when not initialized source" do
      it "should raise error" do
        lambda {
          @input_spec[0]
        }.should raise_error SourceDataNotProvidedError
      end
    end
  end

  describe "#value_at" do
    context "when initialized source" do
      before(:each) do
        @values = %W(1 2 3 4 5 6 7 8 9)
        @input_spec.source = @values
      end

      context "when access existing index" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at(3)
          }
        end

        it "should get value" do
          @proc.call.should == @values[3]
        end
      end

      context "when access non-existing index" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at(@values.size)
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end
    end

    context "when not initialized source" do
      it "should raise error" do
        lambda {
          @input_spec.value_at(0)
        }.should raise_error SourceDataNotProvidedError
      end
    end
  end

  describe "#value_at_by_number" do
    context "when initialized source" do
      before(:each) do
        @values = %W(1 2 3 4 5 6 7 8 9)
        @input_spec.source = @values
      end

      context "when access existing number" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at_by_number("7")
          }
        end

        it "should get value" do
          @proc.call.should == @values[6]
        end
      end

      context "when access non-existing number" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at_by_number((@values.size + 1).to_s)
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end
    end

    context "when not initialized source" do
      it "should raise error" do
        lambda {
          @input_spec.value_at_by_number("0")
        }.should raise_error SourceDataNotProvidedError
      end
    end
  end

  describe "#value_at_by_name" do
    context "when initialized source" do
      before(:each) do
        @values = %W(1 2 3 4 5 6 7 8 9)
        @input_spec.source = @values
      end

      context "when access existing name" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at_by_name("item_2")
          }
        end

        it "should get value" do
          @proc.call.should == @values[1]
        end
      end

      context "when access non-existing name" do
        before(:each) do
          @proc = lambda {
            @input_spec.value_at_by_name("unknown")
          }
        end

        it "should raise error UnknownTargetExpressionError" do
          @proc.should raise_error UnknownTargetExpressionError
        end
      end
    end

    context "when not initialized source" do
      it "should raise error" do
        lambda {
          @input_spec.value_at_by_name("item_3")
        }.should raise_error SourceDataNotProvidedError
      end
    end
  end

  describe "#spec_item_by_expression" do
    context "when access existing index" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression(3)
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "4"
      end
    end

    context "when access non-existing index" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression(9)
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end

    context "when access existing number" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("7")
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "7"
      end
    end

    context "when access non-existing number" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("10")
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end

    context "when access existing name" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("item_2")
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "2"
      end
    end

    context "when access non-existing name" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("unknown")
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end

    context "when access valid calculation expression" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("CALC::[[1]]+[[2]]")
        }
      end

      it "should not raise error" do
        @proc.should_not raise_error
      end

      it { @proc.call.should == [@input_spec.spec_item_at_by_number("1"),
                                 @input_spec.spec_item_at_by_number("2")] }
    end

    context "when access invalid calculation expression with unknown number" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("CALC::[[1]]+[[12]]")
        }
      end

      it "should raise UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end

    context "when access invalid calculation expression with syntax error" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_by_expression("CALC::[[1]][[2]]")
        }
      end

      it { @proc.call.should == [@input_spec.spec_item_at_by_number("1"),
                                 @input_spec.spec_item_at_by_number("2")] }
    end
  end

  describe "#spec_item_at" do
    context "when access existing index" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at(3)
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "4"
      end
    end

    context "when access non-existing index" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at(9)
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end
  end

  describe "#spec_item_at_by_number" do
    context "when access existing number" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at_by_number("7")
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "7"
      end
    end

    context "when access non-existing number" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at_by_number("10")
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end
  end

  describe "#spec_item_at_by_name" do
    context "when access existing name" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at_by_name("item_2")
        }
      end

      it "should get spec item" do
        @proc.call.number.should == "2"
      end
    end

    context "when access non-existing name" do
      before(:each) do
        @proc = lambda {
          @input_spec.spec_item_at_by_name("unknown")
        }
      end

      it "should raise error UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end
  end
end
