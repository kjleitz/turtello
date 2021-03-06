class User < ApplicationRecord
  extend FriendlyId

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

  validates :username,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[a-zA-Z0-9_-]+\z/,
      message: "must only include letters, numbers, underscores, and/or hyphens"
    }

  friendly_id :username, use: :slugged

  enum role: {
    peasant: 0,
    admin: 1,
    moderator: 2,
  }

  def messages_with(buddy)
    condition = <<~SQL
      ("messages"."sender_id" = :id AND "messages"."receiver_id" = :buddy_id)
      OR ("messages"."sender_id" = :buddy_id AND "messages"."receiver_id" = :id)
    SQL
    bindings = { id: id, buddy_id: buddy.id }
    Message.arrived.where(condition, bindings)
  end

  def message_thread_ids
    MessageThread.involving(self).ids
  end

  def message_threads
    MessageThread.involving(self)
  end

  def thread_ids
    message_thread_ids
  end

  def threads
    message_threads
  end

  def generate_token
    secret = Rails.application.secret_key_base
    JWT.encode({ user_id: id }, secret, 'HS256')
  end
end
