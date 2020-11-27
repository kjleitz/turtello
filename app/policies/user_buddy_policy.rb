class UserBuddyPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where('"user_buddies"."user_id" = :user_id OR "user_buddies"."buddy_id" = :user_id', { user_id: user.id })
    end
  end

  def index?
    logged_in?
  end

  def show?
    return false unless logged_in?
    user.admin? || user.id == record.user_id || user.id == record.buddy_id
  end

  def create?
    return false unless logged_in?
    user.admin? || user.id == record.user_id
  end

  def update?
    return false unless logged_in?
    user.admin? || user.id == record.user_id
  end

  def destroy?
    return false unless logged_in?
    user.admin? || user.id == record.user_id
  end
end
