class Notice < ActiveRecord::Base
	belongs_to :user
 	validates :title, presence: true, length: {minimum: 5 ,maximum:15}
end
