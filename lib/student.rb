require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL 
            CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY,
            name TEXT,
            grade TEXT
            ); 
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql = <<-SQL
              UPDATE students SET name = ?, grade = ? WHERE id = ?
            SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-SQL
              INSERT INTO students (name, grade) VALUES (?, ?)
            SQL
      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
    self
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
  end

  def self.new_from_db(r)
    new_student = self.new(r[1],r[2])
    new_student.id = r[0]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM students WHERE name = ?
          SQL
    r = DB[:conn].execute(sql,name).first
    self.new(r[1],r[2],r[0])
  end

  def update
    sql = <<-SQL
            SELECT * FROM students WHERE id = ?
          SQL
    r = DB[:conn].execute(sql,self.id).first
    student = Student.new(self.name,self.grade,r[0])
    student.save
  end
end
