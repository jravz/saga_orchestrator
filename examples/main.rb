require 'saga_orchestrator'
require_relative 'workflow_models/definitions/test'

obj = Saga::Orchestrator::new(Workflows::Test, 30)
puts obj.run()
puts obj.execution_sequence
