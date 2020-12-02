class MessageThreadSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  link(:self) do |message_thread|
    user, buddy = message_thread.participants
    "/users/#{user.id || 0}/message_threads/#{buddy.id || 0}"
  end

  attributes(*%i[
    slug
    created_at
    updated_at
  ])

  has_many :messages, serializer: MessageSerializer
  has_many :participants, serializer: UserSerializer
end
