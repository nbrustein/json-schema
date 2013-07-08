require 'test/unit'
require File.dirname(__FILE__) + '../../lib/json-schema'

begin
  require 'active_model'
  
  class JSONActiveModelModule < Test::Unit::TestCase
  
    class TestModel
      include ActiveModel::Model
      include JSON::Schema::ActiveModelWithJsonSchema
      
      self.json_schema = {
        "type" => "object",
        "required" => ["required"],
        "properties" => {
          "required" => {"type" => "string"}
        }
      }
    end
  
    def test_validating_against_schema
      assert_equal true, TestModel.new({'required' => "defined"}).valid?
      invalid_instance = TestModel.new({})
      assert_equal false, invalid_instance.valid?
      assert invalid_instance.errors.full_messages.first.match("Json schema not honored. The property '#/' did not contain a required property of 'required' in schema")
    end
  
  end
  
rescue
  
end