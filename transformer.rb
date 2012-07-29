require "./parser.rb"

class DinoTransformer < Parslet::Transform
  # rule(:int => simple(:int))        { IntLit.new(int) }
  # rule(
  #   :left => simple(:left), 
  #   :right => simple(:right), 
  #   :op => '+')                     { Addition.new(left, right) }
  # rule(
  #   :funcall => 'puts', 
  #   :arglist => subtree(:arglist))  { FunCall.new('puts', arglist) }
    
  def self.apply(tree, print_parse = false)
    begin
      pp tree
      
      new.apply(tree).tap do |parsed_tree|
        if print_parse
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

if ARGV[0] == "test"
  puts "+--------------------------------------------------------+"
  puts "| TRANSFORMER TESTS                                      |"
  puts "+--------------------------------------------------------+"

  Transformer.apply("(1 + 2)")

  puts "\n...complete."
end