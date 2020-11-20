class Message < ApplicationRecord
  belongs_to :sender, class_name: "User", inverse_of: :sent_messages
  belongs_to :receiver, class_name: "User", inverse_of: :received_messages

  validates :sender, presence: true
  validates :receiver, presence: true
  validates :body, presence: true
end
