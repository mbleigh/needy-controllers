ActionController::Base.send :include, Intridea::StyleChain
ActionView::Base.send :include, Intridea::StyleChain::Helpers

ActionController::Base.send :include, Intridea::BehaviorChain
ActionView::Base.send :include, Intridea::BehaviorChain::Helpers

ActionController::Base.send :include, Intridea::NeedyControllers
ActionView::Base.send :include, Intridea::NeedyControllers::Helpers