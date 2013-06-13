module Vindicia
  class Parser
    class IncorrectApiRequestError < Exception; end
    class ParsingError < Exception; end

    attr_reader :response, :request_klass_name, :method_name, :output_results

    def initialize(response, klass_name, method_name, output_results)
      @response            = convert_response_to_hash(response)
      @request_klass_name  = klass_name
      @method_name         = method_name
      @output_results      = output_results
    end

    def parse!(&block)
      raise IncorrectApiRequestError, 'Incorrect API request' unless valid?

      method_response = response[method_with_response]
      raise_error_unless_200(method_response)

      if is_response_a_collection?
        process_array_results(method_response, &block)
      else
        process_hash_results(method_response)
      end
    rescue TypeError, NoMethodError => ex
      raise IncorrectApiRequestError, "#{ ex.to_s }\n#{ ex.backtrace }"
    end

    def is_response_a_collection?
      output_results.any? do |output|
        response[method_with_response][output.to_sym].is_a?(Array)
      end
    end

    private

    # Process main output that comes as an Array. (Level 0 outputs)
    # For this specific case parent objects might return an array of objects
    def process_array_results(responses, &block)
      raise(ParsingError, 'a block is required') unless block_given?

      output_results.each do | output |
        output_collection = get_response_output(responses, output)
        next unless output_collection

        output_collection.each do |api_output|
          response_output = result_match_parent_object?(output) ? api_output : { output => api_output }
          yield(response_output)
        end
      end
    end

    # Process the results: if one of the expected output objects
    # matches the class name, all other output attributes will be appended to
    # the original object to act as properties.
    # Otherwise they will be treated as regular attributes from the result output
    def process_hash_results(response)
      returned_hashes = output_results.reduce({}) do | output, result_option |
        api_output = get_response_output(response, result_option)
        next unless api_output

        if result_match_parent_object?(result_option)
          output = api_output.merge!(output)
        else
          output.merge!({ result_option => api_output })
        end
        output
      end
      returned_hashes
    end

    def result_match_parent_object?(return_attribute)
      [request_klass_name, request_klass_name.pluralize].
        include?(return_attribute.to_s.capitalize.camelcase)
    end

    # There's the case when the output of an API operation is not explicit in a
    # result object, but relies on the [:return][:return_code] value.
    # Let's extract that as an object for that specific case.
    # For other cases just return the object
    def get_response_output(response, output)
      (output == :result) ? response[:return][:return_code] : response[output]
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
      response.has_key?(method_with_response) &&
      response[method_with_response].has_key?(:return) &&
      response[method_with_response][:return].has_key?(:return_code)
    end

    def convert_response_to_hash(raw_response)
      unless raw_response.respond_to?(:to_hash)
        raise ParsingError, 'should respond to :to_hash'
      end
      raw_response.is_a?(Hash) ? raw_response : raw_response.to_hash
    end

    def method_with_response
      "#{ method_name.to_s }_response".to_sym
    end
  end
end
