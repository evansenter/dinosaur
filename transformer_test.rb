require "./transformer.rb"

DinoParser.debug      = true
DinoTransformer.debug = true

puts "+--------------------------------------------------------+"
puts "| TRANSFORMER TESTS                                      |"
puts "+--------------------------------------------------------+"

pp DinoTransformer.apply("(+. 1 2 3.0e-2.5)").eval
# pp DinoTransformer.apply("(^ (+ 1 2 3 (- 4 5)) 2)").eval
# pp DinoTransformer.apply("(p (^ (+ 1 2 3 (- 4 5)) 2))").eval

puts "\n...complete."
