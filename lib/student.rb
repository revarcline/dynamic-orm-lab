require_relative '../config/environment'
require 'active_support/inflector'
require 'interactive_record'

# inherit the record
class Student < InteractiveRecord
  column_names.each do |col|
    attr_accessor col.to_sym
  end
end
