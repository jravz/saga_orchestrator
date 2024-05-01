require_relative '../helpers/enum_helper'


module Transactions

  class Parameters
    extend EnumHelper

    enum :type, { input_params: 0, last_result: 1, direct:2, none: 3}

    def initialize
      self.type = :input_params
      @params = nil
    end

    def set_type val
      self.type = val
    end

    def input val
      @params = val
    end


  end

end
