module Cashbox

  # Include in this list any attribute => { class, flag} we want to handle in
  # its own class to avoid creating a sub-class or even an array of items
  CUSTOM_ATTRIB_TO_CLASS = {
    name_values: { class_name: 'NameValues', create_single_object: true },
    autobills:   { class_name: 'AutoBill', create_single_object: false },
    autobill:    { class_name: 'AutoBill', create_single_object: false },
    giftcard:    { class_name: 'GiftCard', create_single_object: false },
  }

  CUSTOM_ATTRIB_RENAME = {
    vid:        'VID',
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
