class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when 'admin' then scope.all
      when 'moderator' then scope.all
      else scope.where(id: user.id) # TODO: better scope for peasants
      end
    end
  end

  def index?
    logged_in?
  end

  def show?
    logged_in?
  end

  def create?
    true
  end

  def update?
    return false unless logged_in?
    user.admin? || user.id == record.id
  end

  def destroy?
    return false unless logged_in?
    user.admin? || user.id == record.id
  end
end
