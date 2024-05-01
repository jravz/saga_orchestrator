module Rollback
  class Test
    def self.rollback input
      input * 100000
    end

    def self.rollback2 input
      raise StandardError, "Rollback error occurred"
    end

  end
end
