module Vindicia
  class << self
    def config
      Vindicia::Configuration.instance
    end

    def configure
      if config.is_configured?
        raise Vindicia::Configuration::ConfigError, 'already configured'
      end

      yield config

      unless Vindicia::API_CLASSES.has_key?(config.api_version)
        raise Vindicia::Configuration::ConfigError,
              "unsupported api version: #{ config.api_version }"
      end

      initialize_savon!
      initialize_client!
      initialize!
      initialize_cashbox_classes!
      config.configured!
    end

    private

    # Creates the required methods to communicate with the API for each class
    def initialize!
      classes = Vindicia::API_CLASSES[config.api_version]
      classes.each do |vindicia_klass, methods_with_output|
        const_set(
          vindicia_klass.to_s.camelize,
          Class.new do
            include Vindicia::Model
            actions(*methods_with_output)
          end
        )
      end
    end

    # Initializes the Singleton Savon instance. All Savon::Client
    # instances will inherit the configuration of this object
    def initialize_savon!
      Savon.configure do |conf|
        conf.pretty_print_xml   = Vindicia.config.pretty_print_xml
        conf.log                = Vindicia.config.general_log
        conf.logger             = Vindicia.config.logger
        if conf.logger
          conf.logger.filter    = Vindicia.config.log_filter
          conf.logger.level     = Vindicia.config.log_level
        end
      end
    end

    # Initializes an instance of the Savon::Client object by using the
    # config arguments. This is shared across Vindicia Objects by singleton
    def initialize_client!
      Vindicia.config.client =
        Savon::Client.new do
          http.headers['Pragma']    = 'no-cache'
          http.auth.ssl.verify_mode = Vindicia.config.ssl_verify_mode
          wsdl.endpoint             = Vindicia.config.endpoint
          wsdl.namespace            = Vindicia.config.namespace
          HTTPI.log                 = false
        end
    end

    # Initializes the Cashbox main classes.
    # Sub-classes are created as per request call on the fly.
    def initialize_cashbox_classes!
      Vindicia::API_CLASSES[config.api_version].each_key do |klass_name|
        Cashbox.get_or_create_class(klass_name.to_s.capitalize.camelcase)
      end
    end
  end
end
