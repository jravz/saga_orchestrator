Gem::Specification.new do |s|
  s.name        = "saga_orchestrator"
  s.version     = "0.15"
  s.summary     = "Describe orchestration workflow as definitions and run within a state engine"
  s.description = "Framework to help employ the Saga Orchestration patterns in ruby or rails applications. Secondly, it makes it easier for firms to visualize the entire flow as a set of steps."
  s.authors     = ["Jayanth Ravindran"]
  s.email       = "jayanth.ravindran@gmail.com"
  s.files       = Dir['lib/**/*','images/*', 'examples/**/*','MIT-LICENSE', 'Readme.md']
  s.homepage    =
    "https://rubygems.org/gems/saga_orchestrator"
  s.license       = "MIT"
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.0'
end
