require "spec_helper"

# Anodator::Message
require "anodator/message"
require "anodator/input_spec"

include Anodator

describe Message, ".new" do
  context "with no parameters" do
    it "should raise ArgumentError" do
      lambda {
        Message.new
      }.should raise_error ArgumentError
    end
  end

  context "with simple template_message" do
    before(:each) do
      @new_proc = lambda {
        Message.new("An error occured!!")
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#template should be provided string" do
      @message = @new_proc.call
      @message.template.should == "An error occured!!"
    end
  end

  context "with template_message include place holder" do
    before(:each) do
      @template = "An error occured [[1::name]]([[1::number]]) must not be [[1::value]]"
      @new_proc = lambda {
        Message.new(@template)
      }
    end

    it "should not raise error" do
      @new_proc.should_not raise_error
    end

    it "#template should be provided string" do
      @message = @new_proc.call
      @message.template.should == @template
    end
  end
end

describe Message, "#expand" do
  before(:each) do
    # create input spec and data source
    @input_spec = InputSpec.new([
                                 { :number => "1", :name => "item_1" },
                                 { :number => "2", :name => "item_2" },
                                 { :number => "3", :name => "item_3" },
                                 { :number => "4", :name => "item_4" },
                                 { :number => "5", :name => "item_5" },
                                ])
    @values = %W(1 2 3 4 5)
    @input_spec.source = @values
  end

  context "when message is valid" do
    before(:each) do
      @template = "An error occured [[1::name]]([[1::number]]) must not be '[[1::value]]'"
      @message = Message.new(@template)
      @proc = lambda { @message.expand(@input_spec) }
    end

    it "should not raise error" do
      @proc.should_not raise_error
    end

    it "should equal replacement values" do
      @proc.call.should ==
        "An error occured item_1(1) must not be '1'"
    end
  end

  context "when message's place holder contain unknown field" do
    context "include unknown target_expression" do
      before(:each) do
        @template = "An error occured [[1::name]]([[1::number]]) must not be [[289::value]]"
        @message = Message.new(@template)
        @proc = lambda { @message.expand(@input_spec) }
      end

      it "should raise UnknownTargetExpressionError" do
        @proc.should raise_error UnknownTargetExpressionError
      end
    end
  end

  context "when message's place holder contain unknown field" do
    context "include unknown attribute" do
      before(:each) do
        @template = "An error occured [[1::name]]([[1::number]]) must not be [[1::values]]"
        @message = Message.new(@template)
        @proc = lambda { @message.expand(@input_spec) }
      end

      it "should raise UnknownMessageAttributeError" do
        @proc.should raise_error UnknownMessageAttributeError
      end
    end
  end
end