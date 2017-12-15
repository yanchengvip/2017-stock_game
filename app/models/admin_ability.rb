class AdminAbility
  include CanCan::Ability
  def initialize(user)
    # define admin abilities here ....
    if user.role.to_i == 2
      can :manage, :all
      res = Resource.get_resources 2
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
    end
  end
end