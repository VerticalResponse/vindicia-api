require 'spec_helper'

describe Vindicia::Parser do
  let(:method_name)      { :fetch_by_merchant_product_id }
  let(:klass_name)       { 'Product' }
  let(:result_attribute) { :product }
  let(:output_results)   { [:product] }

  let(:content) { nil }

  let(:response) do
    build_api_response(method_name, result_attribute, content)
  end

  let(:instance) do
    Vindicia::Parser.new(response, klass_name, method_name, output_results)
  end

  describe '#parse!' do
    subject(:call_parse) { instance.parse! }

    context 'for an invalid response hash' do
      context 'given no response' do
        let(:response) { nil }

        it 'should fail gracefully' do
          expect { call_parse }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end

      context 'given no method_response hash' do
        let(:response) do
          { fetch_by_merchant_product_id_response: { return: '200', return_string: 'some' },
            result_attribute => 1
          }
        end

        it 'should fail gracefully due incorrect response' do
          expect { call_parse }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end

      context 'given no return_code' do
        let(:response) do
          { fetch_by_merchant_product_id_response: { returning: '200', return_string: 'some' },
            result_attribute => 1
          }
        end

        it 'should fail gracefully due incorrect response' do
          expect { call_parse }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end

      context 'given no return_code' do
        let(:response) do
          { something_response: { return: '200', return_message: 'some' },
            something: 1
          }
        end

        it 'should fail gracefully due incorrect response' do
          expect { call_parse }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end
    end

    context 'for a valid response code' do
      context 'for a non-200 response code' do
        let(:response) do
          build_api_failed_response(method_name, 'Invalid Format', '401')
        end

        it 'should fail gracefully for anything that 200 response code' do
          expect do
            call_parse
          end.to raise_error(Vindicia::Parser::IncorrectApiRequestError,
                             'Code: 401. Message: Invalid Format')
        end
      end
      context 'for a 500 response code' do
        let(:response) do
          build_api_failed_response(method_name, 'Internal Error', '500')
        end

        it 'should fail gracefully for 500 response code' do
          expect do
            call_parse
          end.to raise_error(Vindicia::Parser::IncorrectApiRequestError,
                             'Code: 500. Message: Internal Error')
        end
      end
    end

    context 'for valid request' do
      let(:response) do
        build_api_response(method_name, result_attribute,
                           { result_attribute => { merchant_product_id: 1 } })
      end

      it 'should not fail for 200 response' do
        expect { call_parse }.to_not raise_error(Vindicia::Parser::IncorrectApiRequestError)
      end

      context 'for a to_hash available object response' do
        it 'should convert to a readable hash the given structure' do
          expect { call_parse }.to_not raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end

      context 'for a non to_hash available object response' do
        let(:response) do
          'any_response: { return:{ return_code: 200, return_string: OK} }'
        end

        it 'should fail gracefully for to_hash convertion when unavailable' do
          expect { call_parse }.to raise_error(Vindicia::Parser::IncorrectApiRequestError)
        end
      end
    end

    context 'for single object request' do
      let(:content) do
        { result_attribute => { merchant_product_id: 1 } }
      end

      it 'should yield to get the correct response' do
        call_parse.should == content
      end
    end
  end

  describe '#parse! given a collection as result' do
    let(:method_name)      { :fetch_all }
    let(:klass_name)       { 'Product' }
    let(:result_attribute) { :products }
    let(:output_results)   { [:products] }
    let(:response) do
      build_api_response(method_name, result_attribute, content)
    end

    let(:instance) do
      Vindicia::Parser.new(response, klass_name, method_name, output_results)
    end

    context 'for a multiple object request' do

      let(:content) do
        [{ product: { merchant_product_id: 1 } },
         { product: { merchant_product_id: 2 } }]
      end

      it 'should yield twice in order to get the correct response' do
        items = []
        instance.parse! do |item|
          items << item
        end
        items.should instance_of(Array)
        items.size.should == 2
      end

      it 'should raise an error of no block is given' do
        expect { instance.parse! }.to raise_error(RuntimeError, 'a block is required')
      end

      it 'should each item have the correct data' do
        items = []
        instance.parse! do |item|
          items << item
        end
        items.should instance_of(Array)
        items.size.should == 2

        items[0].should == content[0]
        items[1].should == content[1]
      end
    end
  end
end
