class MessagePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.involving(user)
    end
  end

  def index?
    logged_in?
  end

  def show?
    return false unless logged_in?
    user.admin? || record.involves?(user)
  end

  def create?
    return false unless logged_in?
    user.id == record.sender_id
  end

  def update?
    return false unless logged_in?
    user.admin? || user.id == record.sender_id
  end

  def destroy?
    return false unless logged_in?
    user.admin? || user.id == record.sender_id
  end
end
