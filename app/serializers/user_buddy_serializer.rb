class UserBuddySerializer
  include JSONAPI::Serializer

  attributes(*%i[
    user_id
    buddy_id
    user_username
    buddy_username
    created_at
    updated_at
  ])
end
