class DinoCore < Object
  def self.method_missing(name, *args, &block)
    if match = name.to_s.match(/^init_with_(.*)?$/)
      prefix    = ->(string, list) { ([string] * list.length).zip(list).map(&:join) }
      arguments = match[1].split("_and_")
      self.class_eval <<-RUBY
        attr_reader #{prefix[":", arguments].join(", ")}
      
        def initialize #{arguments.join(", ")}
          #{prefix["@", arguments].join(", ")} = #{arguments.join(", ")}
        end
      RUBY
    else
      super
    end
  end
  
  def self.functions
    const_defined?(:METHODS) ? const_get(:METHODS) : const_set(:METHODS, {})
  end
  
  def self.add_function(name, &block)
    functions[name] = block
  end
end
