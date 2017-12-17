require 'spec_helper'

# Anodator::Message
require 'anodator/message'
require 'anodator/input_spec'

include Anodator

RSpec.describe Message, '.new' do
  context 'with no parameters' do
    it 'should raise ArgumentError' do
      expect do
        Message.new
      end.to raise_error ArgumentError
    end
  end

  context 'with simple template_message' do
    before(:each) do
      @new_proc = lambda {
        Message.new('An error occured!!')
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    it '#template should be provided string' do
      @message = @new_proc.call
      expect(@message.template).to be == 'An error occured!!'
    end
  end

  context 'with template_message include place holder' do
    before(:each) do
      @template = 'An error occured [[1::name]]([[1::number]]) must not be [[1::value]]'
      @new_proc = lambda {
        Message.new(@template)
      }
    end

    it 'should not raise error' do
      expect(@new_proc).not_to raise_error
    end

    it '#template should be provided string' do
      @message = @new_proc.call
      expect(@message.template).to be == @template
    end
  end
end

RSpec.describe Message, '#expand' do
  before(:each) do
    # create input spec and data source
    @input_spec = InputSpec.new([
                                  { number: '1', name: 'item_1' },
                                  { number: '2', name: 'item_2' },
                                  { number: '3', name: 'item_3' },
                                  { number: '4', name: 'item_4' },
                                  { number: '5', name: 'item_5' }
                                ])
    @values = %w[1 2 3 4 5]
    @input_spec.source = @values
  end

  context 'when message is valid' do
    before(:each) do
      @template = "An error occured [[1::name]]([[1::number]]) must not be '[[1::value]]'"
      @message = Message.new(@template)
      @proc = -> { @message.expand(@input_spec) }
    end

    it 'should not raise error' do
      expect(@proc).not_to raise_error
    end

    it 'should equal replacement values' do
      expect(@proc.call).to be ==
                            "An error occured item_1(1) must not be '1'"
    end
  end

  context "when message's place holder contain unknown field" do
    context 'include unknown target_expression' do
      before(:each) do
        @template = 'An error occured [[1::name]]([[1::number]]) must not be [[289::value]]'
        @message = Message.new(@template)
        @proc = -> { @message.expand(@input_spec) }
      end

      it 'should raise UnknownTargetExpressionError' do
        expect(@proc).to raise_error UnknownTargetExpressionError
      end
    end
  end

  context "when message's place holder contain unknown field" do
    context 'include unknown attribute' do
      before(:each) do
        @template = 'An error occured [[1::name]]([[1::number]]) must not be [[1::values]]'
        @message = Message.new(@template)
        @proc = -> { @message.expand(@input_spec) }
      end

      it 'should raise UnknownMessageAttributeError' do
        expect(@proc).to raise_error UnknownMessageAttributeError
      end
    end
  end
end
