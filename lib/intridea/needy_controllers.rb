module Intridea
  module NeedyControllers
    def self.included(base)
      base.extend(ClassMethods)
      
    end
    
    module ClassMethods
      def needs(options = {})
        unless options[:record].blank?
          add_grab( [options.delete(:record), options] )
          
          before_filter :do_grabs
          include Intridea::NeedyControllers::InstanceMethods
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

      @@grab_options = Array.new
      
      def add_grab(options)
        @@grab_options << options
      end
      
      def grab_options
        @@grab_options
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