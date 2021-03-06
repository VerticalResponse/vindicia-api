require 'savon'
require 'httpclient'
require 'retriable'

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
        @client ||= Savon::Client.new(&block)
      end

      def endpoint(uri)
        client.wsdl.endpoint = uri
      end

      def namespace(uri)
        client.wsdl.namespace = uri
      end

      def ssl_verify_mode(mode)
        client.http.auth.ssl.verify_mode = mode
      end

      def ssl_version(version)
        client.http.auth.ssl.ssl_version = version
      end

      def cert_file(file)
        client.http.auth.ssl.cert_file = file
      end

      def ca_cert_file(file)
        client.http.auth.ssl.ca_cert_file = file
      end

      def cert_key_file(file)
        client.http.auth.ssl.cert_key_file = file
      end

      def cert_key_pwd(pwd)
        client.http.auth.ssl.cert_key_password = pwd
      end

      def open_timeout(timeout)
        client.http.open_timeout = timeout
      end

      def read_timeout(timeout)
        client.http.read_timeout = timeout
      end

      # This method has to match the retriable callback
      # https://github.com/kamui/retriable/blob/eaab7caba015389adf1b892e9bec4e97f9430eda/lib/retriable.rb#L70
      # on_retry.call(exception, try, elapsed_time, interval) if on_retry
      def log_retry(ex, attempt, elapsed_time, interval)
        Vindicia.config.logger.warn("Attempt #{attempt} failed, elapsed time: #{elapsed_time}, interval: #{interval}, message: #{ex.message} | Retrying...") if Vindicia.config.logger
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
        escaped_action = Vindicia::API_ACTION_NAME_RESERVED_BY_RUBY_MAPS[action] || action
        class_action_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{action.to_s.underscore}(body = {}, &block)
            Retriable.retriable :on       => [ HTTPClient::ConnectTimeoutError, Net::OpenTimeout, Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNRESET],
                                :tries    => Vindicia.config.max_connect_attempts,
                                :multiplier => Vindicia.config.retry_multiplier,
                                :on_retry => method(:log_retry) do
              client.request :tns, #{escaped_action.inspect} do
                soap.namespaces["xmlns:tns"] = vindicia_target_namespace
                http.headers["SOAPAction"] = vindicia_soap_action('#{escaped_action}')
                soap.body = {
                  :auth => vindicia_auth_credentials
                }.merge(body)
                block.call(soap, wsdl, http, wsse) if block

              end
            end
          rescue HTTPClient::ConnectTimeoutError, Net::OpenTimeout, Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNRESET => e
            rescue_exception(:#{ escaped_action.to_s.underscore }, '503', e.message)
          rescue Exception => e
            raise if %w(Mocha::ExpectationError WebMock::NetConnectNotAllowedError).include? e.class.name
            rescue_exception(:#{ escaped_action.to_s.underscore }, '500', e.message)
          end
        RUBY
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
