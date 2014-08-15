require 'savon'
require 'httpclient'

module Vindicia

  # = Vindicia::Model
  #
  # Model for SOAP service oriented applications.
  module Model

    module ClassMethods

      def self.extend_object(base)
        super
        base.init_vindicia_model
      end

      def init_vindicia_model
        class_action_module
      end

      def client(&block)
        @client ||= Savon::Client.new &block
      end

      def endpoint(uri)
        client.wsdl.endpoint = uri
      end

      def namespace(uri)
        client.wsdl.namespace = uri
      end

      # Accepts one or more SOAP actions and generates both class and instance methods named
      # after the given actions. Each generated method accepts an optional SOAP body Hash and
      # a block to be passed to <tt>Savon::Client#request</tt> and executes a SOAP request.
      def actions(*actions)
        actions.each do |action|
          define_class_action action
        end
      end

    private

      def define_class_action(action)
        real_action = API_ACTION_NAME_RESERVED_BY_RUBY_MAPS[action] || action
        class_action_module.module_eval <<-CODE
          def #{action.to_s.underscore}(body = {}, &block)
            client.request :tns, #{ real_action.inspect } do
              soap.namespaces["xmlns:tns"] = vindicia_target_namespace
              http.headers["SOAPAction"] = vindicia_soap_action('#{ real_action }')
              soap.body = explicit_type_attributes_for({
                :auth => vindicia_auth_credentials
              }.merge(body))
              block.call(soap, wsdl, http, wsse) if block
            end
          rescue HTTPClient::ConnectTimeoutError, Timeout::Error, Errno::ETIMEDOUT => e
            rescue_exception(:#{ action.to_s.underscore }, '503', e.message)
          rescue Exception => e
            rescue_exception(:#{ action.to_s.underscore }, '500', e.message)
          end
        CODE
      end

      def api_version(version)
        @api_version = version
      end

      def login(login)
        @login = login
      end

      def password(password)
        @password = password
      end

      def vindicia_class_name
        name.demodulize
      end

      def vindicia_auth_credentials
        {login: @login, password: @password, version: @api_version}
      end

      def explicit_type_attributes_for(hash)
        r = hash.inject({}) do |h, (k,v)|
          h[k] = case v
                 when Hash
                   explicit_type_attributes_for(v)
                 else
                   v
                 end
          h
        end

        explicit_fields = EXPLICIT_FIELD_TYPES.keys & hash.keys
        if explicit_fields.any?
          r[:attributes!] = explicit_fields.inject({}) do |e,f|
            e[f] = FIELD_TYPE_ATTRIBUTES[EXPLICIT_FIELD_TYPES[f]]
            e
          end
        end

        r
      end

      def vindicia_target_namespace
        "#{client.wsdl.namespace}/v#{ underscoreize_periods(@api_version) }/#{ vindicia_class_name }"
      end

      def underscoreize_periods(target)
        target.gsub(/\./, '_')
      end

      def vindicia_soap_action(action)
        %{"#{ vindicia_target_namespace}##{ action.to_s.camelize(:lower) }" }
      end

      def rescue_exception(action, code, message)
        { "#{action}_response".to_sym => {
          return: {
            return_code:    code,
            return_string:  message,
          } }
        }
      end

      def class_action_module
        @class_action_module ||= Module.new do
          # confused why this is needed
        end.tap { |mod| extend mod }
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

  end
end
