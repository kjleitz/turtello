class UserBuddySerializer
  include JSONAPI::Serializer

  set_key_transform :camel_lower

  link(:self) { |user_buddy| "/user_buddies/#{user_buddy.id || 0}" }

  attributes(*%i[
    user_id
    buddy_id
    user_username
    buddy_username
    created_at
    updated_at
  ])
end
