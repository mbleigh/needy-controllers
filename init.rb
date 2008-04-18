require 'intridea/needy_controllers'

ActionController::Base.send :include, Intridea::StyleChain
ActionView::Base.send :include, Intridea::StyleChain::Helpers

ActionController::Base.send :include, Intridea::BehaviorChain

ActionView::Base.send :include, Intridea::BehaviorChain::Helpers
ActionView::Base.send :alias_method_chain, :javascript_include_tag, :needs

ActionController::Base.send :include, Intridea::NeedyControllers

ActionView::Base.send :include, Intridea::NeedyControllers::Helpers
ActionView::Base.send :alias_method_chain, :stylesheet_link_tag, :needs

class ActiveRecord::Base
  def self.from_param(parameter)
    find(parameter.to_i)
  end
end