require 'wash_out/configurable'
require 'wash_out/soap_config'
require 'wash_out/soap'
require 'wash_out/engine'
require 'wash_out/param'
require 'wash_out/dispatcher'
require 'wash_out/soap'
require 'wash_out/router'
require 'wash_out/type'
require 'wash_out/model'
require 'wash_out/wsse'
require 'wash_out/middleware'
require 'wash_out/nested_param'

module ActionDispatch::Routing
  class Mapper
    # Adds the routes for a SOAP endpoint at +controller+.
    def wash_out(controller_name, options={})
      options.each_with_index { |key, value|  @scope[key] = value } if @scope
      controller_class_name = [options[:module], controller_name].compact.join("/")

      match "#{controller_name}/wsdl"   => "#{controller_name}#_generate_wsdl", :via => :get, :format => false
      match "#{controller_name}/action" => WashOut::Router.new(controller_class_name), :via => [:get, :post], :defaults => { :controller => controller_class_name, :action => '_action' }, :format => false
    end
  end
end

Mime::Type.register "application/soap+xml", :soap
ActiveRecord::Base.send :extend, WashOut::Model if defined?(ActiveRecord)

ActionController::Renderers.add :soap do |what, options|
  _render_soap(what, options)
end

ActionController::Base.class_eval do

  # Define a SOAP service. The function has no required +options+:
  # but allow any of :parser, :namespace, :wsdl_style, :snakecase_input,
  # :camelize_wsdl, :wsse_username, :wsse_password and :catch_xml_errors.
  #
  # Any of the the params provided allows for overriding the defaults
  # (like supporting multiple namespaces instead of application wide such)
  #
  def self.soap_service(options={})
    include WashOut::SOAP
    self.soap_config = options
  end
end

module WashOut
    def self.is_active_record_object? return_option
      # return_option = return_option.first
      return_value = Array(return_option).first
      return return_value.is_a? ActiveRecord::Base
    end

    def self.is_active_record_definition? thing
      thing = thing.first if thing.is_a? Array
      return true if thing.is_a? NestedParam
      return thing.any?{|x| is_active_record_class? x} if thing.is_a? Hash
      return is_active_record_class? thing
    end

    def self.is_active_record_class? thing
      return false unless thing.is_a? Class
      return thing.ancestors.include? ActiveRecord::Base
    end

    def self.model_to_definition_hash model
      # puts "model definition_hash:\t#{Hash[model.columns.collect{|c| [c.name.to_sym,convert_type(c.type)] }].pretty_inspect}"
      Hash[model.columns.collect{|c| [c.name.to_sym,convert_type(c.type)] }]
    end

    def self.convert_type type
      from = {
        ntext: :string,
        nvarchar: :string
      }
      from[type.to_sym] || type
    end
end