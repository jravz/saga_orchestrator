class NodeNotRunError < StandardError
  attr_reader :details

  def initialize(message, details = nil)
    super(message)
    @details = details
  end
end

class NodeTargetFunctionMissingError < StandardError
  attr_reader :details

  def initialize(message, details = nil)
    super(message)
    @details = details
  end
end

class NullStateError < StandardError
  attr_reader :details

  def initialize(message, details = nil)
    super(message)
    @details = details
  end
end

class RollbackMethodMissing < StandardError
  attr_reader :details

  def initialize(message, details = nil)
    super(message)
    @details = details
  end
end
