require_relative '../transactions/retriable'
require_relative '../transactions/compensatory'
require_relative './custom_exceptions/exceptions'

module Saga

  class States

    def initialize
      @states = {}
    end

    def standard name, &block
      transac = Transactions::RetriableTransaction::new(name)
      block.call(transac) if block_given?
      @states[name] = transac
    end

    def compensatory name, &block
      transac = Transactions::CompensatoryTransaction::new(name)
      block.call(transac) if block_given?
      if !transac.valid?
        raise RollbackMethodMissing.new("Rollback method missing for compensatory state", { reason: "Add rollback method for compensatory state", code: 1001 })
      end
      @states[name] = transac
    end

    def sequence_states(&block)
      block.call(@sequences) if block_given?
    end

    def get_state_by_name name
      res = @states[name]
      raise NullStateError.new("Attempt to run an undefined state = #{name}.", { reason: "State has not been defined or registered.", code: 1001 }) if res.nil?
      res
    end

    def keys
      @states.keys
    end

  end

end
