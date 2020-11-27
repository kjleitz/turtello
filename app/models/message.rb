class Message < ApplicationRecord
  belongs_to :sender, class_name: "User", inverse_of: :sent_messages
  belongs_to :receiver, class_name: "User", inverse_of: :received_messages
  belongs_to :message_thread, class_name: "MessageThread", inverse_of: :messages

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :message_thread, presence: true
  validates :body, presence: true
  validates :arrives_at, presence: true

  scope :en_route, -> { where(arrives_at: ...Time.zone.now) }
  scope :arrived, -> { where(arrives_at: Time.zone.now..) }
  scope :delivered, -> { arrived }

  before_validation :set_default_arrives_at!
  before_validation :create_thread_if_none_exists!

  class << self
    def involving(user)
      where(
        '"messages"."sender_id" = :user_id OR "messages"."receiver_id" = :user_id',
        { user_id: user.id }
      )
    end
  end

  def thread
    message_thread
  end

  def thread=(thread)
    self.message_thread=(thread)
  end

  def thread_id
    message_thread_id
  end

  def thread_id=(thread_id)
    self.message_thread_id=(thread_id)
  end

  def sender_username
    sender.username
  end

  def receiver_username
    receiver.username
  end

  def arrived?
    !!arrives_at && arrives_at <= Time.zone.now
  end

  def delivered?
    arrived?
  end

  def en_route?
    !arrived?
  end

  def involves?(user)
    user.id == sender_id || user.id == receiver_id
  end

  private

  def set_default_arrives_at!
    self.arrives_at ||= Time.zone.now
  end

  def create_thread_if_none_exists!
    self.message_thread ||= MessageThread.find_or_create_for(sender, receiver)
  end
end
