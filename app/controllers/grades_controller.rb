class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update]

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
      count_student_major(@grades)
      count_student_department(@grades)
    elsif student_logged_in?
      @grades=current_user.grades
      @grade_true=Array.new
      @grades.each do |every_grades|
      if every_grades.grade then
         @grade_true.push every_grades
      end
    end 
    @grades=@grade_true
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
    return  @grades
  end


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
  
  #统计学生专业情况  listen
def count_student_major(grades)
    @grades=grades
    @major=[]
    @grades.each do |grade|
      @major.push(grade.user.major)
    end
    @hs = Hash.new
    @major.each { |e|
        if @hs.has_key?(e)
            @hs[e] += 1
        else
            @hs[e] = 1
        end
        }
    @tip_name=@hs.keys
    @student_count=@hs.values
    return @tip_name,@student_count
end
  
    #统计学生单位情况  listen
def count_student_department(grades)
    @grades=grades
    @department=[]
    @grades.each do |grade|
      @department.push(grade.user.department)
    end
    @hs_department = Hash.new
    @department.each { |e|
        if @hs_department.has_key?(e)
            @hs_department[e] += 1
        else
            @hs_department[e] = 1
        end
        }
    @department_name=@hs_department.keys
    @department_count=@hs_department.values
    return @department_name,@department_count
end

end
