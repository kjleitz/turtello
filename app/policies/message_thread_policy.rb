class MessageThreadPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user.message_thread_ids)
    end
  end

  def index?
    logged_in?
  end

  def show?
    return false unless logged_in?
    user.admin? || record.involves?(user)
  end
end
