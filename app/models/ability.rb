class Ability
  include CanCan::Ability

  def initialize(user)

    if user.role.to_i == 1
      can :manage, :all
      res = Resource.get_resources 1
      res.each do |r|
        begin
          model_n = r['model_n']
          action_n = r['action_n']
          model_n_c = model_n.safe_constantize
          if model_n_c.blank?
            #如果model不存在，则为Controller的名字
            #cannot :index,'LuckyBag'.underscore.to_sym #LuckyBagsController
            cannot action_n.to_sym, model_n.underscore.to_sym

          else
            cannot action_n.to_sym, model_n_c
          end

        rescue Exception => e

        end

      end

    elsif [2, 3].include? user.role.to_i
      can :manage, :all
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admins?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
