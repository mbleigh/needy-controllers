module Intridea
  module BehaviorChain
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def behaves_with(*behaviors)
        if behaviors.last.is_a?(Hash)
          options = behaviors.pop
          behaviors = behaviors.collect{|s| s.to_s }
          update_behavior_conditions(behaviors,options)
        else
          behaviors = behaviors.collect{|s| s.to_s }
        end
        append_behavior_to_chain(behaviors)
      end
      
      def included_behavior_actions #:nodoc:
        @included_behavior_actions ||= read_inheritable_attribute('included_behavior_actions') || {}
      end
  
      # Returns a mapping between behaviors and actions that may not include them.
      def excluded_behavior_actions #:nodoc:
        @excluded_behavior_actions ||= read_inheritable_attribute('excluded_behavior_actions') || {}
      end
      
      def behavior_chain
        read_inheritable_attribute('behavior_chain') || []
      end
      
      def behavior_excluded_from_action?(behavior,action)
        case
        when ia = included_behavior_actions[behavior]
          !ia.include?(action)
        when ea = excluded_behavior_actions[behavior]
          ea.include?(action)
        else
          false
        end
      end
      
      def allowed_behaviors_for(action)
        behavior_chain.reject{ |behavior| 
          behavior_excluded_from_action?(behavior,action)
        }
      end
      
      protected
      
        def append_behavior_to_chain(behaviors)
          new_behavior_chain = behavior_chain + behaviors
          write_inheritable_attribute('behavior_chain',new_behavior_chain)
        end
  
        def update_behavior_conditions(behaviors, conditions)
          return if conditions.empty?
          if conditions[:only]
            write_inheritable_hash('included_behavior_actions', behavior_condition_hash(behaviors, conditions[:only]))
          elsif conditions[:except]
            write_inheritable_hash('excluded_behavior_actions', behavior_condition_hash(behaviors, conditions[:except]))
          end
        end  
        
        def behavior_condition_hash(behaviors, *actions)
          actions = actions.flatten.map(&:to_s)      
          behaviors.flatten.map(&:to_s).inject({}) { |h,s| h.update( s => (actions.blank? ? nil : actions)) }
        end
    end
    
    module Helpers
      def javascript_include_tag_with_needs(*sources)
        if sources.include?(:needs)
          sources = sources[0..(sources.index(:needs))] + 
            controller.class.allowed_behaviors_for(controller.action_name) + 
            sources[(sources.index(:needs) + 1)..sources.length]          
            
          sources.delete(:needs)
        end
        javascript_include_tag_without_needs(*sources)
      end
    end
  end
end