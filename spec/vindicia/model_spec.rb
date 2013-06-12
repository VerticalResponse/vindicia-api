require 'spec_helper'

describe Vindicia::Model do
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
    end
  end

  describe '.client' do
    it 'should contain a savon initialized object' do
      Vindicia::Product.client.should instance_of(Savon::Client)
    end

    it 'should be the same client as the Vindicia::Configuration' do
      Vindicia::Product.client.should == Vindicia.config.client
    end
  end

  describe '.actions' do
    context 'single word class name' do
      it 'should exist a class name' do
        Vindicia.const_defined?('Product').should be_true
      end

      it 'should contain fetch_all method with no argument' do
        Vindicia::Product.methods.should include(:fetch_all)
      end

      it 'should contain fetch_by_merchant_product_id method' do
        Vindicia::Product.methods.should include(:fetch_by_merchant_product_id)
      end
    end

    context 'few words class name' do
      it 'should exist a class name' do
        Vindicia.const_defined?('BillingPlan').should be_true
      end

      it 'should contain fetch_all method with no argument' do
        Vindicia::BillingPlan.methods.should include(:fetch_all)
      end

      it 'should contain fetch_by_merchant_product_id method' do
        Vindicia::BillingPlan.methods.should include(:fetch_by_merchant_billing_plan_id)
      end
    end
  end

  describe 'a generated method for a single class object' do
    let(:valid_response) do
      build_api_response(:fetch_by_merchant_product_id, :product, content)
    end
    let(:content) do
      { 'VID' =>             'abc123',
        merchant_product_id: 'NEW_PRODUCT',
        status:              'Active',
      }
    end
    let(:argument) do
      { merchant_product_id: 'NEW_PRODUCT' }
    end

    subject(:call_api_method) do
      Vindicia::Product.fetch_by_merchant_product_id(argument)
    end

    context 'given an argument' do
      before(:each) do
        mock(Vindicia::Product).raw_fetch_by_merchant_product_id(argument) { valid_response }
      end

      it 'should accept a hash as argument' do
        dont_allow(Vindicia::Product).
          raw_fetch_by_merchant_product_id.with_no_args { valid_response }

        call_api_method.should_not be_nil
      end

      it 'should return a Cashbox::Product object' do
        call_api_method.should instance_of(Cashbox::Product)
        call_api_method.merchant_product_id.should == argument[:merchant_product_id]
      end
    end

    context 'given an 500 error code' do
      let(:error_response) do
        build_api_failed_response(:fetch_by_merchant_product_id,
                                  'Failed to communicate with Vindicia',
                                  '500')
      end

      it 'should fail gracefully' do
        mock(Vindicia::Product).raw_fetch_by_merchant_product_id(argument) { error_response }
        expect { call_api_method }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
      end
    end
  end

  describe 'a generated method for a collection of objects' do
    let(:valid_response) do
      build_api_response(:fetch_all, :products, content)
    end
    let(:content) do
      [
        { 'VID' =>             'abc123',
          merchant_product_id: 'NEW_PRODUCT',
          status:              'Active'
        },
        { 'VID' =>             'xyz321',
          merchant_product_id: 'NEW_PRODUCT_2',
          status:              'Inactive'
        },
      ]
    end

    subject(:call_collection_api_method) do
      Vindicia::Product.fetch_all
    end

    context 'given an argument' do
      before(:each) do
        mock(Vindicia::Product).raw_fetch_all({}) { valid_response }
      end

      it 'should accept no arguments' do
        call_collection_api_method.should_not be_nil
      end

      it 'should return a collection of Cashbox::Product objects' do
        call_collection_api_method.should instance_of(Array)
        call_collection_api_method.each do |item|
          item.should instance_of(Cashbox::Product)
          item.merchant_product_id.should include 'NEW_PRODUCT'
        end
      end
    end
  end
end
