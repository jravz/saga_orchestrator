module Saga

  class RunState

    def initialize state_name
      @state_name = state_name
      @status = nil
      @time_of_run = Time.now.gmtime
      @input = nil
      @result = nil
      @error = nil
    end

    def initialize state_name, result
      @state_name = state_name
      @status = nil
      @time_of_run = Time.now.gmtime
      @result = nil
      @error = nil

      update(result)
    end

    def update result
      @status = result&.[](:status)

      case @status
      when :success
        @result = result[:result]
      when :error
        @error = result[:message]
      when :rollback
        @result = result[:result]
      end
    end

    def outcome
      outcome = ''

      case @status
      when :success
        outcome = @result
      when :error
        outcome = @error
      when :rollback
        outcome = @result
      end

      outcome
    end

    def unwrap
      {
        state_name: @state_name,
        status: @status,
        time_of_run: @time_of_run,
        outcome: outcome()
      }
    end

  end

  class RunStates
    def initialize
      @run_states = []
    end

    def push state_name, result
      @run_states.push(RunState::new(state_name,result))
    end

    def dump
      results = {}
      ctr = 0
      @run_states.each do |rs|
        results[ctr] = rs.unwrap()
        ctr += 1
      end

      results
    end
  end

end
