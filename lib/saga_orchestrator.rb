require_relative 'state_management/state_manager'
require_relative 'state_management/state_engine'
 module Saga
  class Orchestrator

    def initialize(cls_state_engine, *args)
      @args = args
      obj = cls_state_engine.new(*@args)
      @state_manager = StateManager::new(obj)
    end

    def run()
      @state_manager.run()

      res = {}

      if @state_manager.success?
        res[:status] = :success
        res[:result] = @state_manager.result
      elsif @state_manager.rollback?
        res[:status] = :rollback
        res[:result] = @state_manager.result
      else
        res[:status] = :error
        res[:result] = @state_manager.error
      end

      return res

    end

    def execution_sequence()
      @state_manager.execution_sequence
    end

  end

end
