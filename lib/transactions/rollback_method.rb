require_relative './parameters'
module Transactions

  class RollbackMethod

    def initialize
      @method_to_call = nil
      @params = Parameters::new()
    end

    def call func_name
      @method_to_call = func_name
    end

    def method
      @method_to_call
    end

    def params &block
      block.call(@params) if block_given?
    end

  end

end
