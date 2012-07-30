require "./transformer.rb"

DinoParser.debug      = true
DinoTransformer.debug = true

puts "+--------------------------------------------------------+"
puts "| TRANSFORMER TESTS                                      |"
puts "+--------------------------------------------------------+"


solution = DinoTransformer.apply("(+. 1 2 2e3 .4)").eval
puts "Solution: "
pp solution
puts "\n" * 3

solution = DinoTransformer.apply("(^. (+. 1 2 3 (-. 4 5)) 2)").eval
puts "Solution: "
pp solution
puts "\n" * 3

solution = DinoTransformer.apply("(p (^. (+. 1 2 3 (-. 4 5)) 2))").eval
puts "Solution: "
pp solution
puts "\n" * 3

puts "...complete."
