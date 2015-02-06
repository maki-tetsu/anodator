require "spec_helper"
require "tempfile"

# Anodator::Utils
require "anodator"
require "anodator/utils"

include Anodator

describe Utils, ".load_input_spec_from_csv_file" do
  context "read valid file" do
    before(:each) do
      @file = Tempfile.new(["input_spec", ".csv"])

      # Header
      @file.puts(["id", "name", "type"].join(","))
      # values
      @values = [
                 { :id => "1", :name => "Name",     :type => "STRING"  },
                 { :id => "2", :name => "Age",      :type => "NUMERIC" },
                 { :id => "3", :name => "Birtyday", :type => "DATE"    },
                 { :id => "4", :name => "Sex",      :type => "NUMERIC" },
                 { :id => "5", :name => "Email",    :type => "STRING"  },
                ]
      @values.each do |v|
        @file.puts("#{v[:id]},#{v[:name]},#{v[:type]}")
      end
      @file.close

      @proc = lambda {
        Utils.load_input_spec_from_csv_file(@file.path)
      }
    end

    after(:each) do
      @file.unlink
    end

    it { @proc.should_not raise_error }

    it "should have all items" do
      input_spec = @proc.call
      @values.each do |value|
        input_spec.spec_item_by_expression(value[:id]).should_not be_nil
      end
    end
  end
end
