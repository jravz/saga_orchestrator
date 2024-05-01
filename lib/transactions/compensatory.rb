require_relative './rollback_method'
require_relative './transaction'

module Transactions

  class CompensatoryTransaction < Transaction

    def initialize name
      super(name)
      @rollback = nil
    end

    def valid?
      !(
        @rollback.nil?
      )
    end

    def rollback_method &block
      @rollback = Transactions::RollbackMethod::new()
      block.call(@rollback) if block_given?
    end

    def on_error_action e
      begin
        case @parameters.type
        when :direct
          input = @parameters.input
          res = @rollback.method.call(input)
        when :last_result
          input =  @last_result
          res = @rollback.method.call(input)
        else
            res = @rollback.method.call(*@input_params)
        end

        @result = {
          status: :rollback,
          result: res
        }

        return @result
      rescue Exception => e
        error_message = "Error in rollback at state (#{@name}) : #{e.message}"
        @error = {
          status: :error,
          message: error_message
        }
        return @error
      end
    end

  end

end
