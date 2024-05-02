require '../lib/saga_orchestrator'
require_relative 'workflow_models/definitions/test'

obj = Saga::Orchestrator::new(Workflows::Test, 3000)
puts obj.run()
puts obj.execution_sequence
