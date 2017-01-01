class AddCourseIntroduction < ActiveRecord::Migration
  def change
    add_column :courses, :course_introduction, :string, :default => "课程介绍"
  end
end
