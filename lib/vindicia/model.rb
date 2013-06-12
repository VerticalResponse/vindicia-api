require 'savon'

module Vindicia
  module Model
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def self.extend_object(base)
        super
        base.init_vindicia_model
      end

      def init_vindicia_model
        class_action_module
      end

      def client(&block)
        Vindicia.config.client
      end

      # Creates the methods to call the API.
      #   raw_<method_name>
      #     in which the http object is correctly setup. Private method
      #   <method_name>
      #     which calls the first 'raw_' method and parses the response,
      #        once parsed, creates or uses the Cashbox::Class to create object
      #
      def actions(*methods)
        methods.each do |method_name, result_options|
          define_api_call_routine(method_name)
          define_class_action(method_name, result_options)
        end
      end

      private

      # Calls the raw_<method_name> function to retrieve response from Vindicia
      # Then parses the Savon Response object into a hash.
      # NOTE: The result might be polymorphic (Hash || Array)
      def define_class_action(method_name, result_options)
        method_name = method_name.to_s.underscore

        class_action_module.module_eval <<-CODE
          def #{ method_name.to_s.underscore }(body = {}, &block)
            result = self.send('raw_#{ method_name }', body, &block)
            parser = Vindicia::Parser.new(result, klass_name, :#{method_name}, #{result_options})

            if parser.is_response_a_collection?
              collection = []
              parser.parse! do |result_item|
                collection << Cashbox.const_get(klass_name).new(result_item)
              end
              collection
            else
              klass = Cashbox.const_get(klass_name)
              klass.new(parser.parse!)
            end
          rescue Vindicia::Parser::IncorrectApiRequestError => ex
            raise ex
          end
        CODE
      end

      # Creating a raw_<method_name> class that handle the actual API call
      # Making it private in favor of the use of the Parser
      def define_api_call_routine(method_name)
        class_action_module.module_eval <<-CODE
          private; def raw_#{ method_name.to_s.underscore }(body = {}, &block)
            request = client.request :tns, #{ method_name.inspect } do
              soap.namespaces["xmlns:tns"] = target_namespace
              http.headers["SOAPAction"] = soap_action_from_name('#{ method_name }')
              soap.body = {
                :auth => auth_credentials
              }.merge(body)
              block.call(soap, wsdl, http, wsse) if block
            end
          rescue Exception => e
            rescue_exception(:#{ method_name.to_s.underscore }, e)
          end
        CODE
      end

      def klass_name
        name.demodulize
      end

      def auth_credentials
        { login:    Vindicia.config.login,
          password: Vindicia.config.password,
          version:  Vindicia.config.api_version }
      end

      def target_namespace
        "#{client.wsdl.namespace}/v#{underscoreize_periods(Vindicia.config.api_version)}/#{klass_name}"
      end

      def underscoreize_periods(target)
        target.gsub(/\./, '_')
      end

      def soap_action_from_name(method_name)
        %{"#{target_namespace}##{method_name.to_s.camelize(:lower)}"}
      end

      def rescue_exception(method_name, error)
        { "#{method_name}_response".to_sym => {
          return: {
            return_code: '500',
            return_string: "Error contacting Vindicia: #{error.message}" }
        } }
      end

      def class_action_module
        @class_action_module ||= Module.new do
          # confused why this is needed
        end.tap { |mod| extend mod }
      end
    end
  end
end
