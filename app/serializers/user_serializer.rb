class UserSerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  link(:self) { |user| "/users/#{user.id || 0}" }

  attributes(*%i[
    username
    role
    created_at
    updated_at
  ])

  has_many :user_buddies, serializer: UserBuddySerializer
  has_many :buddies, serializer: UserSerializer
end
