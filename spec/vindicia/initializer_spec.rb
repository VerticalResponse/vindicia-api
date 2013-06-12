require 'spec_helper'

describe Vindicia do

  let(:valid_api_version) { '4.0' }

  let!(:config_instance) do
    Vindicia.configure do |config|
      config.api_version      = valid_api_version
      config.login            = 'something'
      config.password         = 'something'
      config.endpoint         = 'something'
      config.namespace        = 'something'
      config.general_log      = true
      config.log_level        = 'something'
      config.log_filter       =  [:password, :login]
      config.logger           = 'something'
      config.pretty_print_xml = true
      config.ssl_verify_mode  = :none
    end
  end

  describe '.config' do
    it 'should return the instance variable' do
      Vindicia.config.should be_instance_of(Vindicia::Configuration)
    end
  end

  describe '.configure' do
    it 'should fail gracefully if its already configured' do
      expect do
        Vindicia.configure { |config| config.api_version = valid_api_version }
      end.to raise_error('Vindicia-api gem has already been configured')
    end

    it 'should fail gracefully if is already configured' do
      mock(Vindicia.config).is_configured? { false }
      expect do
        Vindicia.configure { |config| config.api_version = '3.0' }
      end.to raise_error(RuntimeError, 'Vindicia-api gem doesn\'t support api version 3.0')
    end

    it 'should initialize a Savon Client' do
      Vindicia.config.client.should instance_of(Savon::Client)
    end

    it 'should initialize a Savon::Client with config arguments' do
      Vindicia.config.client.http.auth.ssl.verify_mode.should == :none
      Vindicia.config.client.config.pretty_print_xml.should   be_true
      Vindicia.config.client.config.logger.should_not         be_nil
      Vindicia.config.client.wsdl.endpoint.should             == 'something'
      Vindicia.config.client.wsdl.namespace.should            == 'something'
      Vindicia.config.client.config.logger.filter             == [:password, :login]
      Vindicia.config.client.config.logger.level              == 'something'
    end

    context 'for class initializers' do
      Vindicia::API_CLASSES['4.0'].each do |klass_name, values|
        it "should have a created Vindicia::#{ klass_name.to_s.capitalize.camelcase } class" do
          Vindicia.const_defined?(klass_name.to_s.capitalize.camelcase).should be_true
        end

        values.each do |method_name, result_values|
          it "should have created a #{ method_name } method" do
            Vindicia.const_get(klass_name.to_s.capitalize.camelcase).
              respond_to?(method_name).should be_true
          end
        end

        it "should have a created Cashbox::#{ klass_name.to_s.capitalize.camelcase } class" do
          Cashbox.const_defined?(klass_name.to_s.capitalize.camelcase).should be_true
        end
      end
    end
  end
end
