module Intridea
  module NeedyControllers
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def needs(options = {})
        unless options[:record].blank?
          memoize_record(options.delete(:record), options)
        else
          unless options[:styles].nil?
            styles = options[:styles].is_a?(Array) ? options[:styles] : Array.new << options[:styles]
            styles << options
            styles_with *styles
          end
          unless options[:scripts].nil?
            scripts = options[:scripts].is_a?(Array) ? options[:scripts] : Array.new << options[:scripts]
            scripts << options
            behaves_with *scripts
          end
        end  
      end
      
      def does_not_need(arg)
        if arg.is_a?(Hash)
          if arg[:styles]
            does_not_style_with(*arg[:styles])
          end
          if arg[:scripts]
            does_not_behave_with(*arg[:scripts])
          end
        elsif arg == :anything
          flush_styles
          flush_behaviors
        elsif arg == :any_styles
          flush_styles
        elsif arg == :any_scripts
          flush_behaviors
        end
      end
      
      private

      def memoize_record(record, options)
        options[:as]     ||= record
        options[:from]   ||= :id
        
        class_eval <<-RUBY
          def #{options[:as].to_s}
            if #{record.to_s.camelize.constantize}.respond_to?(:from_param)
              @#{options[:as].to_s} ||= #{record.to_s.camelize.constantize}.from_param(params[:#{options[:from].to_s}])
            else
              @#{options[:as].to_s} ||= #{record.to_s.camelize.constantize}.find_by_id(params[:#{options[:from].to_s}])
            end
          end
          
          helper_method :#{options[:as].to_s}
        RUBY
      end
    end
  end
end