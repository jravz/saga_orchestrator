module Saga

  class StateManager

    def initialize obj_state_engine
      @state_engine = obj_state_engine
    end

    def run
      @state_engine.state_registration
      @state_engine.sequence_states
      @state_engine.run
    end

    def success?
      @state_engine.success?
    end

    def rollback?
      @state_engine.rollback?
    end

    def result
      @state_engine.result
    end

    def error
      @state_engine.error
    end

    def execution_sequence
      @state_engine.execution_sequence
    end

  end

end
