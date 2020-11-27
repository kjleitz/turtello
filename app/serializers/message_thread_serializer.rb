class MessageThreadSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  attributes(*%i[
    slug
    created_at
    updated_at
  ])

  has_many :messages, serializer: MessageSerializer
  has_many :participants, serializer: UserSerializer
end
