class HomesController < ApplicationController

  def index
       @course_to_choose=Course.where('open = true') 
       @notice = Notice.order(created_at: :desc).limit(5)
  	@courses = Course.order("student_num DESC")
  	len = 5
  	if(@courses.length < len)
	  	len = @course.length
	end 
  	@top_courses = Array.new
	  (1..len).each do |i|
	  	@top_courses.push(@courses[i-1].course_code+" "+@courses[i-1].name+
	  		" "+@courses[i-1].teacher.name+" "+@courses[i-1].student_num.to_s+"/"+@courses[i-1].limit_num.to_s)
	  end
  end

end
