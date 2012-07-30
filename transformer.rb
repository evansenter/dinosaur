require "awesome_print"
require "./parser.rb"

class Array
  def self.wrap(object)
    object.kind_of?(Array) ? object : [object]
  end
end

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

DinoNil = Class.new(DinoCore) do
  def eval; nil; end
  def inspect; "DinoNil"; end
end.new

class DinoBase < DinoCore
  class << self; attr_accessor :context; end
  attr_reader :expressions
  
  def initialize(expressions)
    @expressions       = expressions
    self.class.context = self
  end
  
  add_function("p") do |*arguments|
    p(*arguments.map(&:eval))
    DinoNil
  end
  
  def eval
    until expressions.empty?
      result = expressions.shift.eval
    end
    
    result
  end
end

class DinoCall < DinoCore
  init_with_function_name_and_arguments
  
  def eval
    puts "Eval: #{function_name} with #{arguments.map(&:class).join(', ')}"
    arguments.map! { |i| i.is_a?(DinoCall) ? i.eval : i }
    
    if function_name.end_with?(?.)
      resolve(arguments.first.class, function_name[0..-2])[arguments.first, *arguments[1..-1]]
    else
      resolve(DinoBase.context.class, function_name)[*arguments]
    end
  end
  
  def resolve(context, function_name)
    # Simple method resolution.
    original_context = context
    
    while context != Object
      if function = context.functions[function_name]
        return function
      else
        context = context.superclass
      end
    end
    
    raise "Method not found: '#{function_name}' starting at context #{original_context.name}"
  end
end

class DinoNumber < DinoCore
  {
    "+" => "+",
    "-" => "-",
    "*" => "*",
    "/" => "/",
    "%" => "%",
    "^" => "**"
  }.each do |dino_method, ruby_method|
    add_function(dino_method) do |this, *list|
      list.inject(this) do |memo, value|
        case solution = memo.eval.send(ruby_method, value.eval)
        when Float   then DinoFloat.new(solution)
        when Integer then DinoInt.new(solution)
        else raise solution
        end
      end
    end
  end
end

class DinoFloat < DinoNumber
  init_with_value
  
  def eval
    @eval ||= value.to_f
  end
end

class DinoInt < DinoNumber
  init_with_value
  
  def eval
    @eval ||= value.to_i
  end
end

class DinoTransformer < Parslet::Transform
  class << self; attr_accessor :debug; end
  
  rule(number: { float: subtree(:data) }) { DinoFloat.new(data[:value][:exponent] ? data[:value][:significand].to_f ** data[:value][:exponent].to_f : data[:value][:significand].to_f) }
  rule(number: { integer: subtree(:data) }) { DinoInt.new(data[:value]) }
  
  rule(f_name: simple(:f_name)) { f_name.to_s }
  
  rule(call: subtree(:data)) { DinoCall.new(data.first, data[1..-1]) }
  
  rule(expressions: subtree(:data)) { DinoBase.new(Array.wrap(data)) }
    
  def self.apply(string, print_parse = true)
    new.apply(DinoParser.parse(string)).tap do |parsed_tree|
      if print_parse
        puts "AST:"
        pp parsed_tree
      end
    end
  end
end