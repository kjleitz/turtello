class MessageSerializer
  include JSONAPI::Serializer

  attributes(*%i[
    sender_id
    receiver_id
    sender_username
    receiver_username
    body
    created_at
    updated_at
  ])
end
