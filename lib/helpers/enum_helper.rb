module EnumHelper
  def enum(name, values)
    # Define instance variable
    attr_reader name

    define_method("#{name}=") do |arg1|
      instance_variable_set("@#{name}",arg1)
    end

    # Define supporting methods
    values.each_key do |key|
      define_method("#{key}?") do
        instance_variable_get("@#{name}") == key
      end
    end
  end
end
