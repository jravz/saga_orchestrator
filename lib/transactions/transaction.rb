require_relative './parameters'
require_relative './transaction'

module Transactions
  class Transaction

    def initialize name
      @name = name
      @method_to_call = nil
      @parameters = nil
      @input_processing_function = nil
      @output_processing_function = nil
      @input_params = nil
      @last_result = nil
      @result = nil
      @error = nil
    end

    def call func_name
      @method_to_call = func_name
    end

    def state_name
      @name
    end

    def params &block
      obj_param = Parameters::new()
      block.call(obj_param) if block_given?
      @parameters = obj_param
    end

    def process_input process_func
      @input_processing_function = process_func
    end

    def process_output process_func
      @output_processing_function = process_func
    end

    def param_type
      @parameters.type
    end

    def on_error_action e

      @error =  {
        status: :error,
        message: "Error in processing at state (#{@name}): #{e.message}"
      }

      @error

    end

    def execute input_params, last_state_result

      res = nil
      input = nil

      @input_params = input_params
      @last_result = last_state_result

      begin
        case @parameters.type
        when :direct
          input = @input_processing_function.nil? ? @parameters.input : @input_processing_function.call(@parameters.input)
          res = @method_to_call.call(input)
        when :last_result
          input = @input_processing_function.nil? ? @last_result : @input_processing_function.call(@last_result)
          res = @method_to_call.call(input)
        when :none
          res = @method_to_call.call()
        else
          if @input_processing_function.nil?
            res = @method_to_call.call(*@input_params)
          else
            res = @method_to_call.call(@input_processing_function.call(*@input_params))
          end
        end

        if !@output_processing_function.nil?
          res = @output_processing_function.call(res)
        end

        @result = {
          status: :success,
          result: res
        }

        return @result
      rescue Exception => e
        return on_error_action(e)
      end

    end

  end
end
