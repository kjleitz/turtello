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

  validates :username, presence: true, uniqueness: true
end
