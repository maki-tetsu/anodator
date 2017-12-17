module Anodator
  module Common
    def check_instances(value_and_classes, exception_class)
      value_and_classes.each do |value_and_class|
        v = value_and_class[0]
        c = value_and_class[1]

        raise exception_class, "#{v} must be #{c}" unless v.is_a? c
      end
    end
  end
end
