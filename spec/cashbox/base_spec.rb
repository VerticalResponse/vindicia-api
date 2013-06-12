require 'spec_helper'

describe Cashbox::Base do

  class Cashbox::Testing < Cashbox::Base
  end

  let(:raw_api_response) do
    full_response = build_api_response(:fetch_by_merchant_product_id, :product, content)
    full_response[:fetch_by_merchant_product_id_response][:product]
  end

  subject(:call_initialize) { Cashbox::Testing.new(raw_api_response) }
  
  describe '#initialize' do
    let(:content) do
      {
        '@xsi:type'.to_sym  =>      'vin:Product',
        merchant_product_id:        'NEW_PRODUCT',
        status:                     'Active',
        descriptions: {
          '@xsi:type'.to_sym =>     'vin:ProductDescription',
          description:              'Our new created Product',
          language:                 'EN',
        },
        default_billing_plan: {
          '@xsi:type'.to_sym  =>    'vin:BillingPlan',
          merchant_billing_plan_id: 'Billing Plan 1',
          periods: {
            '@xsi:type'.to_sym  =>  'vin:BillingPlanPeriod',
            type:                   'Month',
            quantity:                1,
            cycles:                  0,
          }
        },
        name_values:[
          { name: 'NAME1', value: 'value1', '@xsi:type'.to_sym  => 'vin:NameValuePair' },
          { name: 'nAMe2', value: 'value2', '@xsi:type'.to_sym  => 'vin:NameValuePair' }
        ],
        merchant_entitlement_ids:[
          { id: 'entitLEMENt1', '@xsi:type'.to_sym  => 'vin:MerchantEntitlementId' },
          { id: 'entitlement2', '@xsi:type'.to_sym  => 'vin:MerchantEntitlementId' },
        ]
      }
    end

    it 'should be a Cashbox::Testing class' do
      call_initialize.should instance_of(Cashbox::Testing)
    end

    it 'should inherit from Cashbox::Base' do
      Cashbox::Testing.should < Cashbox::Base
    end

    it 'should contain native attributes' do
      call_initialize.methods.should include(:status, :merchant_product_id)
    end

    it 'should contain sub-object attributes' do
      call_initialize.methods.should include(:descriptions, :default_billing_plan)
    end

    context 'given children objects' do
      it 'each sub-object should be its own class' do
        # Can't use instance_of in this case since the class hasn't been
        # initialized yet
        call_initialize.descriptions.class.to_s.should          == 'Cashbox::ProductDescription'
        call_initialize.default_billing_plan.class.to_s.should  == 'Cashbox::BillingPlan'
        call_initialize.name_values.class.to_s.should           == 'Cashbox::NameValues'
        call_initialize.merchant_entitlement_ids.should instance_of(Array)
      end

      it 'should not contain an array of name_values' do
        # According to this mapping: Cashbox::ATTRIBUTE_CUSTOM_CLASS
        call_initialize.name_values.class.to_s.should == 'Cashbox::NameValues'
        call_initialize.name_values.methods.should_not include(:name_values)
      end
    end

    context 'given a sub-object inside a sub-object' do
      it 'each sub-objects sub-object should be its own class' do
        call_initialize.default_billing_plan.periods.class.to_s.should == 'Cashbox::BillingPlanPeriod'
      end

      it 'should include native attributes' do
        call_initialize.default_billing_plan.periods.methods.should include(:quantity, :type)
      end
    end

    context 'given elements with no @xsi:type' do
      it 'attribute should map the attribute name' do
        call_initialize.merchant_entitlement_ids.class.to_s.should_not == 'Cashbox::MerchantEntitlementId'
        call_initialize.merchant_entitlement_ids.each do |ent|
          ent.class.to_s.should == 'Cashbox::MerchantEntitlementId'
        end
      end
    end

    context 'given Array of elements as children object' do
      it 'Array elements map to an Array unless specified' do
        call_initialize.merchant_entitlement_ids.should instance_of(Array)
      end

      it 'Array elements doesnt map to array if specified' do
        call_initialize.name_values.should_not instance_of(Array)
      end
    end
  end

  describe 'only simple attributes' do
    let(:content) do
      {
        '@xsi:type'.to_sym  =>  'vin:Product',
        merchant_product_id:    'NEW_PRODUCT',
        status:                 'Active',
      }
    end

    it 'should initialize correclty with simple attributes' do
      call_initialize.methods.should include(:merchant_product_id, :status)
      call_initialize.methods.should_not include(:name_values)
    end
  end

  describe 'only simple attributes' do
    let(:content) do
      {
        merchant_entitlement_ids:[
          { id: 'entitLEMENt1', '@xsi:type'.to_sym  => 'vin:MerchantEntitlementId' },
          { id: 'entitlement2', '@xsi:type'.to_sym  => 'vin:MerchantEntitlementId' },
        ]
      }
    end

    it 'should initialize correclty with simple attributes' do
      call_initialize.methods.should include(:merchant_entitlement_ids)
      call_initialize.methods.should_not include(:id)
      call_initialize.merchant_entitlement_ids[0].methods.should include(:id)
    end
  end


end
