class MessageSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  attributes(*%i[
    sender_id
    receiver_id
    sender_username
    receiver_username
    body
    created_at
    updated_at
  ])

  belongs_to :sender, serializer: UserSerializer
  belongs_to :receiver, serializer: UserSerializer
end
