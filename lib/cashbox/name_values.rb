module Cashbox
  # Not to be confused with Cashbox::NameValuePair class
  class NameValues < OpenStruct

    attr_reader :raw_name_values

    def initialize(arguments = {})
      @raw_name_values = arguments

      result = initialized_hash
      super(result)
    end

    def to_hash
      { name_values: @raw_name_values }
    end

    private

    def initialized_hash

      # NameValues is polymorphic and might come as a single Hash
      # instead of an Array of Hashes
      arr_name_values = @raw_name_values.is_a?(Array) ? @raw_name_values : [@raw_name_values]

      result = arr_name_values.reduce(Hash.new) do |output, name_value_hash|
        output[name_value_hash[:name].downcase]  = name_value_hash[:value]
        output
      end

      result
    end
  end
end
