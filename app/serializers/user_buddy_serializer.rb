class UserBuddySerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  attributes(*%i[
    user_id
    buddy_id
    user_username
    buddy_username
    created_at
    updated_at
  ])
end
