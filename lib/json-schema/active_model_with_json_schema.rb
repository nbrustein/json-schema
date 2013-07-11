begin
  require 'active_model'
  require 'active_model/validator'
  require 'active_model/serializers/json'

  module JSON
    class Schema
      module ActiveModelWithJsonSchema
      
        def self.included(target)
          target.send(:extend, ActiveModelWithJsonSchemaClassMethods)
          target.send(:cattr_accessor, :json_schema)
        end
        
        def json_schema
          self.class.json_schema
        end
      
      end
    
      module ActiveModelWithJsonSchemaClassMethods
      
        def json_schema=(json_schema)
          self.json_schema = json_schema
          json_schema['properties'].keys.each do |key|
            attr_accessor key.to_sym
          end
          validates_json_schema
        end
      
      end
    end
  end
  
  module ActiveModel
    module Validations
      class JsonSchemaValidator < EachValidator # :nodoc:
      
        def validate_each(record, attribute, value)
          begin
            json_schema = record.json_schema
            JSON::Validator.validate!(json_schema, record.as_json, :validate_schema => true)
          rescue JSON::Schema::ValidationError
            record.errors.add(attribute, "not honored. #{$!.message}")
          end
        end
      end

      module HelperMethods
        # Validates that the record respects the provided json_schema
        #
        #   class Person
        #     include JSON::Schema::ActiveModelWithJsonSchema
        # 
        #     self.json_schema = {
        #       "type" => "object",
        #       "required" => ["required"],
        #       "properties" => {
        #          "required" => {"type" => "string"}
        #       }
        #     }
        #   end
        def validates_json_schema
          validates_with(JsonSchemaValidator, {
            :attributes => [:json_schema]
          })
        end
      end
    end
  end
  
rescue LoadError => e
end