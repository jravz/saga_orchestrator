require_relative './custom_exceptions/exceptions'
require_relative '../transactions/transaction'
require_relative '../helpers/enum_helper'

module Saga

  class SequenceNode
    extend EnumHelper

    enum :type, { process: 0, conditional: 1, stop: 2 }
    enum :action_type, {transaction:0, sequence:1}

    def initialize
      @name = nil
      self.type = :process
      self.action_type = :transaction
      @do = nil
      @parent_node = nil
      @on_success_go = nil
      @on_false_go = nil
      @run_state = nil
    end

    def set_run_status bool
      if bool.is_a?(TrueClass) || bool.is_a?(FalseClass)
        @run_state = bool
      end
    end

    def run params = nil, last_state_result=nil

      if self.type == :stop
        return {status: :close}
      end

      if @do.nil?
        raise NodeTargetFunctionMissingError.new("Node has no target task.", { reason: "State node has no transaction task.", code: 1001 })
      end

      if @do.is_a?(Transactions::Transaction)
        res = @do.execute(params, last_state_result)
        @run_state = true
        @run_state   = false if !res&.[](:result) && self.type == :conditional
        return res
      end

      return nil
    end

    def next

      if @run_state.nil?
        raise NodeNotRunError.new("Node has not been run yet.: #{self.name}", { reason: "Next can only be decided after node has been run.", code: 1001 })
      end

      if @run_state == true
        return @on_success_go
      else
        return @on_false_go
      end
    end

    def set_parent_node node
      @parent_node = node
    end

    def set_do task

      if task.nil?
        raise NullStateError.new("Attempt to run an undefined state.", { reason: "State has not been defined or registered.", code: 1001 })
      end

      if task.is_a?(Sequence)
        @action_type = :sequence
        @name = task.name
        puts "within sequence - #{@name}"
      else
        @name = task.state_name
        puts "within task - #{@name}"
      end
      @do = task
    end

    def name
      @name
    end

    def set_type sym_type
      self.type = sym_type
    end

    def point_to node
      if node.is_a?(Sequence)
        @on_success_go = node.first
      else
        @on_success_go = node
      end
    end

    def set_parent node
      @parent_node = node
    end

    def has_on_fail_pointer?
      !@on_false_go.nil?
    end

    def has_on_success_pointer?
      !@on_success_go.nil?
    end

    def on_fail_point_to node
      if node.is_a?(Sequence)
        @on_false_go = node.first
      else
        @on_false_go = node
      end
    end

    def activity
      @do
    end

    def on_true activity

      seq_node = SequenceNode::new()
      seq_node.set_do activity

      self.point_to seq_node

      seq_node.set_parent_node self

    end

    def on_false activity

      seq_node = SequenceNode::new()
      seq_node.set_do activity

      self.on_fail_point_to seq_node

      seq_node.set_parent_node self

    end

    def on_conditional &block
      block.call(self) if block_given?

      return_nodes = []
      return_nodes.push(@on_success_go) if !@on_success_go.nil?
      return_nodes.push(@on_false_go) if !@on_false_go.nil?
      return_nodes
    end

  end

  class Sequence

    def initialize name
      @name = name
      @prev_node = []
      @initial_node = nil
    end

    def name
      @name
    end

    def first
      @initial_node
    end

    def init task
      seq_node = SequenceNode::new()
      seq_node.set_do task
      @prev_node.push(seq_node)
      @initial_node = seq_node
    end

    def end
      seq_node = SequenceNode::new()
      seq_node.set_type :stop

      begin
        @prev_node.each do |nd|
          nd.point_to seq_node
        end
        seq_node.set_parent_node @prev_node
        @prev_node.clear
        @prev_node.push(seq_node)
      rescue NoMethodError => e
        puts "Within End Error : #{e.message}"
      end

    end

    def then task
      seq_node = SequenceNode::new()
      seq_node.set_do task

      begin
        @prev_node.each do |nd|
          nd.point_to seq_node
        end
        seq_node.set_parent_node @prev_node
        @prev_node.clear
        @prev_node.push(seq_node)
      rescue NoMethodError => e
        puts "Within Then Error : #{e.message}"
      end
    end

    def then_conditional task, &block
      seq_node = SequenceNode::new()
      seq_node.set_do task
      seq_node.set_type :conditional

      begin
        @prev_node.each do |nd|
          nd.point_to seq_node
        end
        seq_node.set_parent_node @prev_node

        @prev_node = seq_node.on_conditional(&block)

      rescue NoMethodError => e
        puts "Within Then Conditional Error : #{e.message}"
      end
    end

  end

  class Sequences

    def initialize
      @sequences = {}
      @active_sequence = nil
      @start = nil
    end

    def get_sequence_by_name name
      @sequences[name]
    end

    def first_node
      @start.first
    end

    def start name, &block
      seq = Sequence::new(name)
      @sequences[name] = seq
      @active_sequence = seq
      @start = seq
      block.call(seq) if block_given?
    end

    #sub sequence of a sequence
    def sub name, &block
      seq = Sequence::new(name)
      @sequences[name] = seq
      @active_sequence = seq
      block.call(seq) if block_given?
    end

  end

end
