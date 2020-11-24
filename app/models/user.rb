class User < ApplicationRecord
  has_secure_password

  has_many :sent_messages,
    class_name: "Message",
    foreign_key: :sender_id,
    inverse_of: :sender,
    dependent: :destroy

  has_many :received_messages,
    class_name: "Message",
    foreign_key: :receiver_id,
    inverse_of: :receiver,
    dependent: :destroy

  has_many :user_buddies,
    class_name: "UserBuddy",
    foreign_key: :user_id,
    inverse_of: :user,
    dependent: :destroy

  has_many :buddies,
    through: :user_buddies,
    source: :buddy,
    class_name: "User"

  has_many :user_stalkers,
    class_name: "UserBuddy",
    foreign_key: :buddy_id,
    inverse_of: :buddy,
    dependent: :destroy

  has_many :stalkers,
    through: :user_stalkers,
    source: :user,
    class_name: "User"

  validates :username, presence: true, uniqueness: true

  def generate_token
    secret = Rails.application.secrets.secret_key_base
    JWT.encode({ user_id: id }, secret, 'HS256')
  end
end
