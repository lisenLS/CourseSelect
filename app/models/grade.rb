class Grade < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  
    #统计学生来自单位情况
  def count_student_department
    @grades
  end
end
