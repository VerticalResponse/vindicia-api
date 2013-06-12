require 'spec_helper'

# Not to be confused with Cashbox::NameValuePair
describe Cashbox::NameValues do
  describe '#initialize' do
    context 'given an array of hashes as input' do
      let(:raw_input) do
        [{ name: 'name1',        value: 'value1' },
         { name: 'CUSTOM',       value: 'CUSTOM_VALUE' },
         { name: 'tHisIsATest1', value: 'Y' }]
      end

      subject(:call_initialize) { Cashbox::NameValues.new(raw_input) }

      it 'should have initialized an object' do
        call_initialize.should instance_of(Cashbox::NameValues)
      end

      it 'should inherit from OpenStruct' do
        Cashbox::NameValues.should < OpenStruct
      end

      it 'should have one attribute per name input attribute' do
        instance = call_initialize
        raw_input.each do |pair|
          instance.methods.should include(pair[:name].downcase.to_sym)
          instance.send(pair[:name].downcase.to_sym).should == pair[:value]
        end
      end
    end

    context 'given a simple hash as input' do
      let(:raw_input) do
        { name: 'my_pair_1', value: 'my_pair_value1' }
      end

      subject(:call_initialize) { Cashbox::NameValues.new(raw_input) }

      it 'should have initialized an object' do
        call_initialize.should instance_of(Cashbox::NameValues)
      end

      it 'should inherit from OpenStruct' do
        Cashbox::NameValues.should < OpenStruct
      end

      it 'should have one attribute per name input attribute' do
        instance = call_initialize
        instance.methods.should include(raw_input[:name].downcase.to_sym)
        instance.send(raw_input[:name].downcase.to_sym).should == raw_input[:value]
      end
    end
  end

  describe '#to_hash' do
    context 'given an array of hashes as input' do
      let(:raw_input) do
        [{ name: 'name1',        value: 'value1' },
         { name: 'CUSTOM',       value: 'CUSTOM_VALUE' },
         { name: 'tHisIsATest1', value: 'Y' }]
      end

      let(:instance) { Cashbox::NameValues.new(raw_input) }

      subject(:call_to_hash) { instance.to_hash }

      it 'should return an instance of Hash' do
        call_to_hash.should instance_of(Hash)
      end

      it 'should contain the same response as the given input' do
        call_to_hash.should == { name_values: raw_input }
      end
    end

    context 'given a simple hash as input' do
      let(:raw_input) do
        { name: 'naME1', value: 'value1' }
      end

      let(:instance) { Cashbox::NameValues.new(raw_input) }

      subject(:call_to_hash) { instance.to_hash }

      it 'should return an instance of Hash' do
        call_to_hash.should instance_of(Hash)
      end

      it 'should contain the same response as the given input' do
        call_to_hash.should == { name_values: raw_input }
      end
    end
  end
end
