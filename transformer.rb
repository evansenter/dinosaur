require "awesome_print"
require "./parser.rb"

class Array
  def self.wrap(object)
    object.kind_of?(Array) ? object : [object]
  end
end

DINO_CORE = {
  "+" => ->(*list) { list.inject(&:+) }
}

class DinoBase < Struct.new(:expressions)
  def eval
    expressions.map(&:eval).last
  end
end

class DinoCall < Struct.new(:function_name, :arguments)
  def eval
    DINO_CORE[function_name][*(arguments.map(&:eval))]
  end
end

class DinoInt < Struct.new(:value)
  def eval
    value.to_i
  end
end

class DinoTransformer < Parslet::Transform
  rule(number: { integer: subtree(:data) }) { DinoInt.new(data[:value]) }
  rule(f_name: simple(:f_name)) { f_name.to_s }
  rule(call: subtree(:data)) { DinoCall.new(data.first, data[1..-1]) }
  rule(expressions: subtree(:data)) { DinoBase.new(Array.wrap(data)) }
    
  def self.apply(string, print_parse = true)
    tree = DinoParser.parse(string)
    
    begin
      new.apply(tree).tap do |parsed_tree|
        if print_parse
          puts "AST:"
          pp parsed_tree
          puts
        end
      end
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
      raise failure
    end
  end
end

if ARGV[0] == "transformer_test"
  puts "+--------------------------------------------------------+"
  puts "| TRANSFORMER TESTS                                      |"
  puts "+--------------------------------------------------------+"

  pp DinoTransformer.apply("(+ 1 2 3 (+ 4 5 6))").eval

  puts "\n...complete."
end