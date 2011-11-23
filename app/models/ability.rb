class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    # Admin users can do anything
    can :manage, :all if user.is_admin?

    ## Plates
    # Researchers may create new plates
    can :create, Plate if user.is_researcher?
    # The creator of a plate may manipulate it as they see fit
    can :manage, Plate, :creator_id => user.id

    ## Database entries
    # As a last resort, look for specific database permission entries 
    user.permissions.each do |permission|
      if permission.subject_id.nil?
        can permission.action.to_sym, permission.subject_class.constantize
      else
        can permission.action.to_sym, permission.subject_class.constantize, :id => permission.subject_id
      end
    end

  end
end