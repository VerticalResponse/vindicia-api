require 'singleton'

module Vindicia
  class Configuration
    include Singleton

    attr_accessor :api_version, :login, :password, :endpoint, :namespace,
                  :general_log, :log_level, :log_filter, :logger,
                  :pretty_print_xml, :ssl_verify_mode, :client

    def initialize
      @configured = false
    end

    def configured!
      @configured = true
    end

    def is_configured?
      @configured
    end
  end
end
