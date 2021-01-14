require_relative '../config/environment'
require 'active_support/inflector'

# we built an active record
class InteractiveRecord
  def self.table_name
    to_s.downcase.pluralize
  end

  def self.column_names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each { |row| column_names << row['name'] }
    column_names.compact
  end

  def initialize(options = {})
    options.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) " \
      "VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    id_sql = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    @id = DB[:conn].execute(id_sql)[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(', ')
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == 'id' }.join(', ')
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute_hash)
    value = attribute_hash.values[0]
    stringed = value.instance_of?(Integer) ? value : "'#{value}'"
    sql = "SELECT * FROM #{table_name} "\
      "WHERE #{attribute_hash.keys[0]} = #{stringed}"
    DB[:conn].execute(sql)
  end
end
