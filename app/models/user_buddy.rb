class UserBuddy < ApplicationRecord
  belongs_to :user, inverse_of: :user_buddies
  belongs_to :buddy, class_name: "User", inverse_of: :user_stalkers

  def user_username
    user.username
  end

  def buddy_username
    buddy.username
  end
end
