module JSON
  class Schema
    class AllOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        # Create an array to hold errors that are generated during validation
        errors = []
        valid = true

        current_schema.schema['allOf'].each do |element|
          schema = JSON::Schema.new(element,current_schema.uri,validator)

          # We're going to add a little cruft here to try and maintain any validation errors that occur in the allOf
          # We'll handle this by keeping an error count before and after validation, extracting those errors and pushing them onto an error array
          pre_validation_error_count = validation_errors(processor).count

          begin
            schema.validate(data,fragments,processor,options)
          rescue ValidationError
            valid = false
          end

          diff = validation_errors(processor).count - pre_validation_error_count
          while diff > 0
            diff = diff - 1
            errors.push(validation_errors(processor).pop)
          end
        end

        if !valid
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match all of the required schemas"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          validation_errors(processor).last.sub_errors = errors
        end
      end
    end
  end
end