# -*- coding: utf-8 -*-
# Simple check example by anodator

require File.join(File.dirname(__FILE__), "..", "lib", "anodator")
include Anodator

### target data columns
# ID, Family name, First name, Sex, Phone number, Birthday, Blood type
input_spec_array_definition =
  [
   { :number => "1", :name => "ID", },
   { :number => "2", :name => "Family name", },
   { :number => "3", :name => "First name", },
   { :number => "4", :name => "Sex", },
   { :number => "5", :name => "Phone number", },
   { :number => "6", :name => "Birthday", },
   { :number => "7", :name => "Blood type", },
  ]
input_spec = InputSpec.new(input_spec_array_definition)


### check rules
rule_set = RuleSet.new
## ID
# ID must be integer number
validator = Validator::NumericValidator.new("1", :only_integer => true)
rule_set << Rule.new("1", Message.new("[[1::name]] must be integer number.([[1::value]])"), validator)

## Family name
# Family name must not be blank
# Family name length must be 2..20
# Family name must be include a-z or A-Z and "'"
validators = []
validators << Validator::PresenceValidator.new("2")
validators << Validator::LengthValidator.new("2", :in => 2..20)
validators << Validator::FormatValidator.new("2", :format => /^[a-z']+$/i)
validator = Validator::ComplexValidator.new(:validators => validators,
                                            :logic => Validator::ComplexValidator::LOGIC_AND)
rule_set << Rule.new("2",
                     Message.new("[[2::name]] must be alphabets or \"'\", maximum length 20 and cannot be blank.([[2::value]])"),
                     validator)

## First name
# Family name must not be blank
# Family name length must be 2..20
# Family name must be include a-z or A-Z and "'"
validators = []
validators << Validator::PresenceValidator.new("3")
validators << Validator::LengthValidator.new("3", :in => 2..20)
validators << Validator::FormatValidator.new("3", :format => /^[a-z']+$/i)
validator = Validator::ComplexValidator.new(:validators => validators,
                                            :logic => Validator::ComplexValidator::LOGIC_AND)
rule_set << Rule.new("3",
                     Message.new("[[3::name]] must be alphabets or \"'\", maximum length 20 and cannot be blank.([[3::value]])"),
                     validator)

## Sex
# Sex is 'M' or 'F'
validator = Validator::InclusionValidator.new("4", :in => %W(M F))
rule_set << Rule.new("4",
                     Message.new("[[4::name]] must be 'M' or 'F'.([[4::value]])"),
                     validator)

## Phone number
# Phone number is only number
# Phone number length must be maximum 12
validators = []
validators << Validator::LengthValidator.new("5", :maximum => 12, :allow_blank => true)
validators << Validator::FormatValidator.new("5", :format => /^[0-9]+$/, :allow_blank => true)
validator = Validator::ComplexValidator.new(:validators => validators,
                                            :logic => Validator::ComplexValidator::LOGIC_AND)
rule_set << Rule.new("5",
                     Message.new("[[5::name]] must be include only integer number and mixumum length is 12.([[5::value]])"),
                     validator)

## Birthday
# Birthday must be YYYY-MM-DD format
validator = Validator::DateValidator.new("6")
rule_set << Rule.new("6",
                     Message.new("[[6::name]] must be date expression.([[6::value]])"),
                     validator)

## Blood type
# Blood type must be include 'A', 'B', 'O' or 'AB'
validator = Validator::InclusionValidator.new("7", :in => %W(A B O AB))
rule_set << Rule.new("7",
                     Message.new("[[7::name]] must be 'A', 'B', 'O' or 'AB'.(([[7::value]]))"),
                     validator)

### output spec
## error list
items =
  [
   "1",
   :target_numbers,
   :error_message,
   :error_level
  ]
output_spec = OutputSpec.new(items,
                             :target => OutputSpec::TARGET_ERROR,
                             :include_no_error => false)

### Checker
checker = Checker.new(input_spec, rule_set, output_spec)

### target datas
datas =
  [
   ["1", "Murayama", "Honoka","F","08050967141","1971-10-01","B"],
   ["2", "Izawa", "Kazuma", "M", "09070028635", "1968-03-24","O"],
   ["3", "Hasebe", "Miyu", "F", "08087224562", "1991-01-21", "A"],
   ["4", "Furusawa", "Eri", "F", "08017372898","1965-02-14", "O"],
   ["5", "Hiramoto", "Yutaka", "M", "", "1986-09-14", "AB"],
   ["6", "Matsuzaki", "Runa", "F", "", "1960-03-27", "O"],
   ["7", "Inagaki", "Kouichi", "M", "", "1961-01-04", "B"],
   ["8", "Kase", "Sueji", "", "", "1969-03-19", "B"],
   ["9", "Kawanishi", "Hinako", "F", "08029628506", "1970-05-29", "B"],
   ["10", "Sakurai", "Eijirou", "M", "", "1988-13-16", "A"],
  ]

### run check for all datas
error_list = []
datas.each do |data|
  error_list += checker.run(data).first
end

error_list.each do |error|
  puts "#{error[0]},#{error[3]},#{error[2]}"
end