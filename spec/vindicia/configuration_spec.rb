require 'spec_helper'

describe Vindicia::Configuration do
  context 'after initialized' do
    subject(:is_initialized) do
      Vindicia::Configuration.instance.configured!
    end

    it 'should change to true after initialized!' do
      Vindicia::Configuration.instance.configured!
      Vindicia::Configuration.instance.is_configured?.should be_true
    end
  end

  context 'not_initialized' do
    subject(:get_instance) do
      Vindicia::Configuration.instance
    end

    it 'should be singleton' do
      new_instance = Vindicia::Configuration.instance
      get_instance.should == new_instance
    end

    it 'should not be a new instance' do
      expect do
        Vindicia::Configuration.new
      end.to raise_error(NoMethodError)
    end
  end

  describe 'attribute assignment' do
    let!(:config_instance) do
      Vindicia.configure do |config|
        config.api_version      = '4.0'
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
        config.client           = 'something'
      end
    end

    it 'should correctly assing attributes' do
      Vindicia.config.api_version.should       == '4.0'
      Vindicia.config.login.should             == 'something'
      Vindicia.config.password.should          == 'something'
      Vindicia.config.endpoint.should          == 'something'
      Vindicia.config.namespace.should         == 'something'
      Vindicia.config.general_log.should       be_true
      Vindicia.config.log_level.should         == 'something'
      Vindicia.config.log_filter.should        == [:password, :login]
      Vindicia.config.logger.should            == 'something'
      Vindicia.config.pretty_print_xml.should  be_true
      Vindicia.config.ssl_verify_mode.should   == :none
      Vindicia.config.client.should            be_instance_of(Savon::Client)
    end
  end
end
