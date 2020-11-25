class UserSerializer
  include JSONAPI::Serializer

  attributes(*%i[
    username
    role
    created_at
    updated_at
  ])
end
