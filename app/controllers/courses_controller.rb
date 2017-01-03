class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end


  def open
    @course=Course.find_by_id(params[:id])
    @course.open_close = true
    @course.save
    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end
  #lixudong:close control
  def close
    @course=Course.find_by_id(params[:id])
    @course.open_close = false
    @course.save 
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end



  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for students----------------------


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
    @course_real_time = get_course_table(@course)
  end
  
  def public_list
     @course=Course.all
  end
  
  def list

    @q1=params[:name]
    if @q1.nil? == false 
      @course = Course.where("name like '#{@q1}' ")
    else
      @course=Course.all
    end

    @course=@course - current_user.courses
    @course_true=Array.new
    @course.each do |every_course|
      if every_course.open_close then
         @course_true.push every_course
      end
    end 
    @course=@course_true
  end

  def select
    @course=Course.find_by_id(params[:id])
    #添加是否选满判断    
    #By  _listen    
    if @course.limit_num.nil?|| @course.student_num<@course.limit_num
       current_user.courses<<@course
       @course.student_num+=1
       @course.save
       flash={:success => "成功选择课程: #{@course.name}"}
       redirect_to courses_path, flash: flash
     else
       flash={danger: "当前课程已满，请选择其他课程: #{@course.name}"}
       redirect_to courses_path, flash: flash         
      end
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  def detail
    @course=Course.find_by_id(params[:id])    #显示课程介绍的方法
    @course_intro = @course.course_introduction
  end

  def course_table
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
    render :json => @course
  end
   
  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:open_close, :course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week, :open_close, 
                                   :course_introduction)
  end
  def get_course_table(courses)
    course_time = Array.new(11) { Array.new(7, '') }
    if courses
      courses.each do |cur|
        cur_time = String(cur.course_time)
        end_j = cur_time.index('(')
        j = week_data_to_num(cur_time[0...end_j])
        t = cur_time[end_j + 1...cur_time.index(')')].split("-")
        for i in (t[0].to_i..t[1].to_i).each
          course_time[(i-1)*7/7][j-1] = cur.name
        end
      end
    end
    course_time
  end

  def week_data_to_num(week_data)
    param = {
        '周一' => 0,
        '周二' => 1,
        '周三' => 2,
        '周四' => 3,
        '周五' => 4,
        '周六' => 5,
        '周天' => 6,
    }
    param[week_data] + 1
  end

end
