class MessageThreadSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  link(:self) do |message_thread|
    user, buddy = message_thread.participants
    "/users/#{user.id || 0}/message_threads/#{buddy.id || 0}"
  end

  has_many :messages, serializer: MessageSerializer
  has_many :participants, serializer: UserSerializer

  attributes(*%i[
    slug
    created_at
    updated_at
  ])

  attribute :participant_usernames do |message_thread|
    message_thread.participants.pluck(:username)
  end

  attribute :latest_message_body do |message_thread|
    message_thread.messages.order(created_at: :desc).first&.body || ""
  end
end
