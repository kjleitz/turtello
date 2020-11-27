class UserSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  attributes(*%i[
    username
    role
    created_at
    updated_at
  ])

  has_many :user_buddies, serializer: UserBuddySerializer
end
