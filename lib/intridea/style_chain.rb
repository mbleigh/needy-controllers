module Intridea
  module StyleChain
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end
    
    module ClassMethods
      def styles_with(*styles)
        if styles.last.is_a?(Hash)
          options = styles.pop
          styles = styles.collect{|s| s.to_s }
          update_style_conditions(styles,options)
        else
          styles = styles.collect{|s| s.to_s }
        end
        append_style_to_chain(styles)
      end
      
      def included_style_actions #:nodoc:
        @included_style_actions ||= read_inheritable_attribute('included_style_actions') || {}
      end
  
      # Returns a mapping between styles and actions that may not include them.
      def excluded_style_actions #:nodoc:
        @excluded_style_actions ||= read_inheritable_attribute('excluded_style_actions') || {}
      end
      
      def style_chain
        read_inheritable_attribute('style_chain') || []
      end
      
      def style_excluded_from_action?(style,action)
        case
        when ia = included_style_actions[style]
          !ia.include?(action)
        when ea = excluded_style_actions[style]
          ea.include?(action)
        else
          false
        end
      end
      
      def allowed_styles_for(action)
        style_chain.reject{ |style| 
          style_excluded_from_action?(style,action)
        }
      end
      
      protected
      
        def append_style_to_chain(styles)
          new_style_chain = style_chain + styles
          write_inheritable_attribute('style_chain',new_style_chain)
        end
  
        def update_style_conditions(styles, conditions)
          return if conditions.empty?
          if conditions[:only]
            write_inheritable_hash('included_style_actions', style_condition_hash(styles, conditions[:only]))
          elsif conditions[:except]
            write_inheritable_hash('excluded_style_actions', style_condition_hash(styles, conditions[:except]))
          end
        end  
        
        def style_condition_hash(styles, *actions)
          actions = actions.flatten.map(&:to_s)      
          styles.flatten.map(&:to_s).inject({}) { |h,s| h.update( s => (actions.blank? ? nil : actions)) }
        end
    end
    
    module Helpers
      def stylesheet_link_tag_with_needs(*sources)
        if sources.include? :needs
          sources = sources[0..(sources.index(:needs))] + 
            controller.class.allowed_styles_for(controller.action_name) + 
            sources[(sources.index(:needs) + 1)..sources.length]          
            
          sources.delete(:needs)
        end
        stylesheet_link_tag_without_needs(*sources)
      end
    end
  end
end