module Cashbox
  class Base < OpenStruct
    attr_reader :raw_api_response

    def initialize(arguments = {})
      @raw_api_response = replace_custom_attributes!(arguments)

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
      marshal_dump.empty?
    end

    def to_hash
      { underscore_klass_name(self.class).to_sym => @raw_api_response }
    end

    private

    # Custom Attributes like :vid are case sensitive, so a replace is needed
    def replace_custom_attributes!(raw_api_response)
      Cashbox::CUSTOM_ATTRIB_RENAME.each do |original_key, new_key|
        if raw_api_response && raw_api_response.has_key?(original_key)
          raw_api_response[new_key] = raw_api_response.delete(original_key)
        end
      end
      raw_api_response
    end

    def joint_hash
      api_native_attrs.merge!(materialized_objects)
    end

    # Keep the global record of key: object to be initialized by this class
    # the object might be a Cashbox::Class object, Array or Native Object
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
    # If the attribute exist in the Cashbox::CUSTOM_ATTRIB_TO_CLASS, use the raw attribute values and their given class
    # Class name is taken either from the @xsi:type object or the attribute key
    def sub_class_initialization!
      api_complex_attrs.each do |attrib_key, attrib_values|
        custom_class_name    = Cashbox::CUSTOM_ATTRIB_TO_CLASS[attrib_key] || {}
        create_single_object = custom_class_name[:create_single_object]

        klass_name =  custom_class_name[:class_name] ||
                      klass_name_from_type(attrib_values) ||
                      klass_name_from_attribute(attrib_key)


        klass = Cashbox.get_or_create_class(klass_name)
        initialize_sub_objects(klass, attrib_key, attrib_values, create_single_object)
      end
    end

    # Initializes a sub-class taking in consideration either the polymorphic
    # input object is an array or hash
    def initialize_sub_objects(klass, attrib_key, values, create_single_object = nil)
      # In case the sub-object is an array. Let's initialize each one and return the arr as it
      new_object = {}
      if values.is_a?(Array) && !create_single_object
        new_object = values.reduce([]) do |output, attributes|
          output << klass.new(attributes)
          output
        end
      else
        new_object = klass.new(values)
      end
      materialized_objects.merge!({ attrib_key => new_object })
    end
  end
end
