class MessageThread < ApplicationRecord
  extend FriendlyId

  has_many :messages,
    class_name: "Message",
    inverse_of: :message_thread,
    dependent: :destroy

  validates :slug,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[0-9]+-[0-9]+\z/,
      message: "must follow the pattern '<lower_user_id>-<higher_user_id>'"
    }

  friendly_id :slug

  class << self
    def slug_for(*participants)
      participants.map(&:id).sort.join('-')
    end

    def find_for(*participants)
      find_by(slug: slug_for(*participants))
    end

    def find_for!(*participants)
      find_by!(slug: slug_for(*participants))
    end

    def find_or_initialize_for(*participants)
      where(slug: slug_for(*participants)).first_or_initialize
    end

    def find_or_create_for(*participants)
      tries_left = 2
      begin
        tries_left -= 1
        where(slug: slug_for(*participants)).first_or_create!
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => error
        # Guarding a possible race condition where the SELECT part of this query
        # finishes and no record is found by the slug, then (elsewhere) a record
        # is INSERTed with the slug, and then (here again) it tries to INSERT a
        # record with the slug just barely too late, causing a uniqueness
        # violation. Retrying the query should do the trick, so the SELECT can
        # grab the newly INSERTed record and make no attempt to create it anew.
        if tries_left.positive?
          retry
        else
          raise error
        end
      end
    end

    def involving(user)
      condition = ['"messages"."sender_id" = :id OR "messages"."receiver_id" = :id', { id: user }]
      distinct.joins(:messages).where(*condition)
    end
  end

  def participant_ids
    messages.distinct.pluck(:sender_id, :receiver_id).flatten.uniq
  end

  def participants
    User.where(id: participant_ids)
  end

  def involves?(user)
    messages.involving(user).any?
  end
end
