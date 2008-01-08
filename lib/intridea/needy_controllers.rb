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
      
      private

      def memoize_record(record, options)
        options[:as]     ||= record
        options[:from]   ||= :id
        
        class_eval <<-RUBY
          def #{options[:as].to_s}
            @#{options[:as].to_s} ||= #{record.to_s.camelize.constantize}.find_by_id(params[:#{options[:from].to_s}])
          end
          
          helper_method :#{options[:as].to_s}
        RUBY
      end
    end 
    
    module InstanceMethods
      def do_grabs
        self.class.grab_options.each do |grab_option|
          grab(*grab_option)
        end
      end
      
      def grab(object, options = {})
      	options[:from] ||= params[:id]
      	options[:except] ||= Array.new
      	options[:only] ||= Array.new
      	options[:as] ||= object

      	if params[:id].nil?
      	  instance_variable_set("@#{options[:as].to_s}", nil)
      	  return
      	end

      	instance_variable_set("@#{options[:as].to_s}", object.to_s.classify.constantize.find(options[:from])) if !options[:except].include?(action_name) or (!options[:only].nil? and options[:only].include?(action_name))
      end
    end
  end
end