require_relative './custom_exceptions/exceptions'
require_relative './states'
require_relative './sequences'
require_relative './run_states'
require_relative '../helpers/enum_helper'

module Saga

  class StateEngine
    extend EnumHelper

    enum :run_status, { success: 0, fail: 1, rollback: 2 }

    def initialize(*args)
      @params = args
      @states = States::new()
      @sequences = Sequences::new()
      @last_result = nil
      @complete = false
      self.run_status = :success
      @error = nil
      @executing_node = nil
      @run_states = RunStates::new()
    end

    def register_states(&block)
      block.call(@states) if block_given?
    end

    def describe_flows(&block)
      @sequences = Sequences::new()
      block.call(@sequences) if block_given?
    end

    def state_name name
      @states.get_state_by_name name
    end

    def sequence_name name
      @sequences.get_sequence_by_name name
    end

    def sequence_states
      keys = @states.keys
      return if keys.size == 0

      describe_flows do |seqs|
        seqs.start :base do |seq|
          keys.each_with_index do |state_name, index|
            if index ==0
              seq.init state_name state_name
            else
              seq.then state_name state_name
            end
          end
          seq.end
        end
      end
    end

    def run

      @executing_node = @sequences.first_node

      if @executing_node.nil?
        raise NullStateError.new("Current sequence has no start node.", { reason: "Sequence not initialised before run.", code: 1001 })
      else
        conduct_sequence @executing_node
      end

    end

    def result
      @last_result
    end

    def error
      @error
    end

    def execution_sequence
      @run_states.dump
    end

    def conduct_sequence active_node
      current_node = active_node

      begin
        if current_node.is_a?(Sequence)
          conduct_sequence current_node.activity.first
        else
          @executing_node = current_node
          res = current_node.run @params, @last_result

          @run_states.push(@executing_node.name, res)

          execution_status = res&.[](:status)
          if execution_status == :close
            @complete = true
            return
          elsif execution_status == :rollback
            self.run_status = :rollback
            @complete = true
          elsif execution_status == :error
            @complete = true
            self.run_status = :fail
            @error = res&.[](:message)
            return
          end
          @last_result = res&.[](:result) if !current_node.conditional? #conditional nodes gives true / false responses which will not be considered as results
        end

        current_node = current_node.next

        if current_node.nil?
          @complete = true
        end

      end while !current_node.nil? && !@complete
    end
  end
end
