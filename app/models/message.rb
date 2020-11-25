class Message < ApplicationRecord
  belongs_to :sender, class_name: "User", inverse_of: :sent_messages
  belongs_to :receiver, class_name: "User", inverse_of: :received_messages

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :body, presence: true
  validates :arrives_at, presence: true

  scope :en_route, -> { where(arrives_at: ...Time.zone.now) }
  scope :arrived, -> { where(arrives_at: Time.zone.now..) }
  scope :delivered, -> { arrived }

  before_validation :set_default_arrives_at!

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

  private

  def set_default_arrives_at!
    self.arrives_at = Time.zone.now if arrives_at.blank?
  end
end
