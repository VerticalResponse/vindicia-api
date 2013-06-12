module Cashbox
  class Base < OpenStruct
    attr_reader :raw_api_response

    def initialize(arguments = {})
      @raw_api_response = arguments

      sub_class_initialization!
      super(joint_hash)
    end

    def api_native_attrs
      return @api_native_attrs if @api_native_attrs
      native = @raw_api_response.select { |key, val| !is_complex_attribute?(val) }
      @api_native_attrs = native || {}
    end

    def api_complex_attrs
      return @api_complex_attrs if @api_complex_attrs
      complex =  @raw_api_response.select { |key, val| is_complex_attribute?(val) }
      @api_complex_attrs = complex || {}
    end

    def empty?
      self.marshal_dump.empty?
    end

    def to_hash
      { underscore_klass_name(self.class).to_sym => @raw_api_response }
    end

    private

    def joint_hash
      api_native_attrs.merge!(materialized_objects)
    end

    def materialized_objects
      @materialized_objects ||= {}
    end

    def is_complex_attribute?(api_object)
      api_object.is_a?(Hash) || api_object.is_a?(Array)
    end

    def underscore_klass_name(klass)
      klass.name.demodulize.to_s.underscore
    end

    # Extracts the Vindicia Object Name out of the returned hash "@xsi:type"
    # the input api_object is polymorphic, therefore the initial transformation
    # Also.. some simple objects (not native) come without a type
    # Eg. "@xsi:type" => "vin:ProductDescription"
    def klass_name_from_type(api_object)
      api_object = [api_object] unless api_object.is_a?(Array)
      type = api_object.first[:"@xsi:type"]
      type.gsub(/vin:/, '') if type
    end

    def klass_name_from_attribute(attribute_name)
      attribute_name.to_s.capitalize.camelize
    end

    # Parses complex sub-objects into their own class based on their :"@xsi:type" type
    # Sub-classes are allowed, that's the reason behind inherit from Cashbox::Base on the new class
    # If the attribute exist in the Cashbox::ATTRIBUTE_CUSTOM_CLASS, use the raw atribute values and their given class
    # Class name is taken either from the @xsi:type object or the attribute key
    def sub_class_initialization!
      api_complex_attrs.each do |attrib_key, attrib_values|
        if Cashbox::ATTRIBUTE_CUSTOM_CLASS.has_key?(attrib_key)
          create_custom_object(attrib_key, attrib_values)
        else
          klass_name = klass_name_from_type(attrib_values) || klass_name_from_attribute(attrib_key)
          klass = Cashbox.get_or_create_class(klass_name)
          initialize_sub_objects(klass, attrib_key, attrib_values)
        end
      end
    end

    # Creates a new object based on the Cashbox::ATTRIBUTE_CUSTOM_CLASS table kay / values
    def create_custom_object(attrib_key, values)
      klass = Cashbox.get_or_create_class(Cashbox::ATTRIBUTE_CUSTOM_CLASS[attrib_key])
      new_object = create_object(klass, values)

      materialized_objects.merge!({ attrib_key => new_object })
    end

    # Initializes a sub-class taking in consideration either the polymorphic
    # input object is an array or hash
    def initialize_sub_objects(klass, attrib_key, values)
      # In case the sub-object is an array. Let's initialize each one and return the arr as it
      new_object = {}
      if values.is_a?(Array)
        new_object = values.reduce([]) do |output, attributes|
          output << create_object(klass, attributes)
          output
        end
      else
        new_object = create_object(klass, values)
      end
      materialized_objects.merge!({ attrib_key => new_object })
    end

    def create_object(klass, attribute_values)
      klass.send(:new, attribute_values)
    end
  end
end
