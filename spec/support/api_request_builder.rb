# Helper method to Build a VALID Vindicia API response to be stubbed
#
# Stubbing example:
#   stub(Vindicia::Product).fetch_all do
#     build_response({ merchant_product_id: 1 }, :product, :fetch_all)
#   end
#
# Arguments:
# method_name => the actual method being called.
#  Eg. If calling the Vindicia::Product.fetch_all provide :fetch_all as argument
#
# result_attribute => returned object.
#   Eg. :product will response in
#       product: { merchant_product_id: .... }
#
# content => actual content:
#   Eg. { merchant_product_id: 1, name_values: [{ name: 'INDEX', value: '1' }] }
#
#
# Using correctly this method you can stub Vindicia::Product.fetch_all call
#
# Output example:
# { fetch_all_response: { return: { return_code: '200', return_string: 'OK' },
#                       { merchant_product_id: 1 }
#
def build_api_response(method_name, result_attribute, content)
  {
    "#{ method_name.to_s }_response".to_sym => {
      return: { return_code: '200',
                return_string: 'OK' },
      result_attribute.to_sym => content
    }
  }
end

# Helper method to Build an INVALID Vindicia API response to be stubbed
#
# Stubbing example:
#   stub(Vindicia::Product).fetch_all do
#     build_response({ merchant_product_id: 1 }, 'product', 'fetch_all')
#   end
#
#
# Arguments:
#
# method_name => the actual method being called.
#  Eg. If calling the Vindicia::Product.fetch_all provide :fetch_all as argument
#
# result_message => actual message from the error.
#   Eg. 'Invalid merchant_product_id'
#
# result_code => return code.
#   Eg. '400'
#
#
# Using correctly this method will stub Vindicia::Product.fetch_all call
#
# Output example:
# { fetch_all_response: { return: { return_code: '400', return_string: 'message' },
#
def build_api_failed_response(method_name, result_message, result_code)
  {
    "#{ method_name.to_s }_response".to_sym => {
      return: { return_code: result_code,
                return_string: result_message }
    }
  }
end
