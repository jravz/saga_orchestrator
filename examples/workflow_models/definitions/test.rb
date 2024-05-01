require 'saga_orchestrator'
require_relative '../processors/test'
require_relative '../functions/test'
require_relative '../rollback/test'

module Workflows
  class Test < Saga::StateEngine

    def state_registration

      register_states do |add_state|

        add_state.standard :sample do |state|
          state.call Functions::Test.method(:test_func)
          state.params do |p|
            p.set_type :input_params
          end
          state.process_output Processors::Test.method(:processor)
        end

        add_state.standard :sample2 do |state|
          state.call Functions::Test.method(:test_func2)
          state.params do |p|
            p.set_type :last_result
          end
          state.process_input Processors::Test.method(:input_processor)
          state.process_output Processors::Test.method(:processor)
        end

        add_state.compensatory :sample3 do |state|
          state.call Functions::Test.method(:test_func3)
          state.params do |p|
            p.set_type :last_result
          end
          state.rollback_method do |rollback|
            rollback.call Rollback::Test.method(:rollback2)
            rollback.params do |p|
              p.set_type :last_result
            end
          end
          state.process_input Processors::Test.method(:input_processor)
          state.process_output Processors::Test.method(:processor)
        end

        add_state.standard :cond01 do |state|
          state.call Functions::Test.method(:conditional_test)
          state.params do |p|
            p.set_type :last_result
          end
        end

      end

    end

    def sequence_states
      describe_flows do |seqs|
        seqs.start :seq_a do |seq|
          seq.init state_name :sample
          seq.then state_name :sample2
          seq.then_conditional state_name :cond01 do |t|
            t.on_true state_name :sample
            t.on_false state_name :sample2
          end
          seq.then state_name :sample3
          seq.end
        end
      end
    end

  end
end
