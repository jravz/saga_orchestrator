module Processors
  class Test
    def self.processor input
      input * 2
    end

    def self.input_processor input
      input / 4
    end
  end
end
