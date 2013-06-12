module Cashbox

  # Include in this list any attribute => class we want to handle in its own class
  # to avoid creaing a sub-class or even an array of items
  ATTRIBUTE_CUSTOM_CLASS = {
    name_values: 'NameValues',
  }

  # Retrieves or creates a new class inherited from Cashbox::Base
  def get_or_create_class(klass_name)
    if Cashbox.const_defined?(klass_name)
       Cashbox.const_get(klass_name)
    else
      Cashbox.const_set(klass_name, Class.new(Cashbox::Base))
    end
  end

  module_function(:get_or_create_class)
end
