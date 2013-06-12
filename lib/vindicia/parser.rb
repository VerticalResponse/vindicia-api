module Vindicia
  class Parser
    class IncorrectApiRequestError < Exception; end

    attr_reader :response, :klass_name, :method_name, :output_results

    def initialize(response, klass_name, method_name, output_results)
      @response       = response
      @klass_name     = klass_name
      @method_name    = method_name
      @output_results = output_results
    end

    def parse!(&block)
      raise IncorrectApiRequestError, 'Incorrect API request' unless valid?

      response = response_hash[method_with_response]
      raise_error_unless_200(response)

      if is_response_a_collection?
        process_array_results(response, &block)
      else
        process_hash_results(response)
      end
    rescue TypeError, NoMethodError => ex
      raise IncorrectApiRequestError, "#{ ex.to_s }\n#{ ex.backtrace }"
    end

    def is_response_a_collection?
      @output_results.any? do |output|
        @response[method_with_response][output.to_sym].is_a?(Array)
      end
    end

    private

    # Process main output that comes as an Array. (Level 0 outputs)
    # For this specific case parent objects might return an array of objects
    def process_array_results(responses, &block)
      @output_results.each do | output |
        output_collection = get_response_output(responses, output)
        next unless output_collection

        output_collection.each do |api_output|
          returned_hashes = {}
          if result_match_parent_object?(output)
            returned_hashes = api_output.merge!(returned_hashes)
          else
            returned_hashes.merge!({ output => api_output })
          end

          block_given? ? yield(returned_hashes) : raise('a block is required')
        end
      end
    end

    # Process the results: if one of the expected output objects
    # matches the class name, all other output attributes will be appended to
    # the original object to act as properties.
    # Otherwise they will be treated as regular attributes from the result output
    def process_hash_results(response)
      returned_hashes = {}
      @output_results.each do | output |
        api_output = get_response_output(response, output)
        next unless api_output

        if result_match_parent_object?(output)
          returned_hashes = api_output.merge!(returned_hashes)
        else
          returned_hashes.merge!({ output => api_output })
        end
      end
      returned_hashes
    end

    def result_match_parent_object?(return_attribute)
      return_attribute = return_attribute.to_s.capitalize.camelcase
      return_attribute == @klass_name || return_attribute == @klass_name.pluralize
    end

    # There's the case when the output of an API operation is not explicit in a
    # result object, but relies on the [:return][:return_code] value.
    # Let's extract that as an object for that specific case.
    # For other cases just return the object
    def get_response_output(response, output)
      output == :result ? response[:return][:return_code] : response[output]
    end

    def raise_error_unless_200(response)
      return_code = response[:return][:return_code]
      unless return_code == '200'
        message = response[:return][:return_string]

        raise IncorrectApiRequestError, "Code: #{ return_code }. Message: #{ message }"
      end
    end

    def valid?
      response &&
      response_hash.has_key?(method_with_response) &&
      response_hash[method_with_response].has_key?(:return) &&
      response_hash[method_with_response][:return].has_key?(:return_code)
    end

    def response_hash
      @response = @response.to_hash if @response.respond_to?(:to_hash)
      @response
    end

    def method_with_response
      "#{ @method_name.to_s }_response".to_sym
    end
  end
end
