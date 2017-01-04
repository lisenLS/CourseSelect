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
    if student_logged_in?
      @course=current_user.courses 
      # haveselected_time(@course)
    end
    return @course
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
    haveselected_time(current_user.courses)
    @course=Course.find_by_id(params[:id])
    if !is_conflict(@course.course_time,@course.course_week)
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
    else
      flash={danger: "课程冲突，请选择其他课程: #{@course.name}"}
       redirect_to courses_path, flash: flash 
    end
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.student_num-=1
    @course.save
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end
  def detail
    @course=Course.find_by_id(params[:id])    #显示课程介绍的方法
    @course_intro = @course.course_introduction
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
  


  def haveselected_time(course)
    @course=course
    @selected_name=[]
    @selected_time=[]
    @selected_week=[]
    @course.each do |course|
      @selected_name.push(course.name)
      @selected_time.push(course.course_time)
      @selected_week.push(course.course_week)
    end
    return @selected_name,@selected_time,@selected_week
  end
  
  def is_conflict(course_time,course_week)
    @day,@class,@week=analy course_time,course_week
    (0 .. @selected_time.length-1).each do |i|
    @s_day,@s_class,@s_week=analy @selected_time[i],@selected_week[i] 
      if !( @week[1]<@s_week[0] ||  @week[0]>@s_week[1]) 
        if @day.eql?(@s_day) 
          if !(@class[1]<@s_class[0] || @class[0]>@s_class[1]) 
            return true
          end
        end
      end
      end
    return false
  end
    
  def analy(course_time,course_week)
    @d=course_time[1]
    @c_s=course_time[3].to_i
    @c_e=course_time[5..6].to_i
    @c=[@c_s,@c_e]
    @w_s=course_week[1].to_i
    @w_e=course_week[3..4].to_i
    @w=[@w_s,@w_e]
    return @d,@c,@w
  end
  
    
end
