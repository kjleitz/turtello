class MessagePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when 'admin' then scope.all
      when 'moderator' then scope.all
      else scope.where('"messages"."sender_id" = :user_id OR "messages"."receiver_id" = :user_id', { user_id: user.id })
      end
    end
  end

  def index?
    logged_in?
  end

  def show?
    return false unless logged_in?
    user.admin? || user.id == record.sender_id || user.id == record.receiver_id
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
