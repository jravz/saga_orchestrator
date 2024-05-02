module Functions
  class Test
    def self.test_func input
      puts "in test_func: input - #{input}"
      res = input + 2
      puts "result = #{res}"
      res
    end

    def self.test_func2 input
      puts "in test_func2: input - #{input}"
      res = input - 10
      puts "result = #{res}"
      res
    end

    def self.test_func3 input
      raise StandardError, "An error occurred"
    end

    def self.test_func4 input
      puts "in test_func: input - #{input}"
      res = input * 10000
      puts "result = #{res}"
      res
    end

    def self.conditional_test input
      res = input > 0
      puts "result = #{res}"
      res
    end

  end
end
