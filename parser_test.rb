require "./parser.rb"

DinoParser.debug = true

puts "+--------------------------------------------------------+"
puts "| PARSER TESTS                                           |"
puts "+--------------------------------------------------------+"

DinoParser.parse("")
DinoParser.parse("\"\"")
DinoParser.parse('""')
DinoParser.parse("'\"\"'")
DinoParser.parse("\"12345\"")
DinoParser.parse("(12345)")
DinoParser.parse("(+ 12345 67890)")
DinoParser.parse("hello")
DinoParser.parse("(hello)")
DinoParser.parse("( hello )")
DinoParser.parse(" ( hello ) ")
DinoParser.parse("\n ( \n hello \n ) \n ")
DinoParser.parse("\n ( \n hello (world) \n ) \n ")
DinoParser.parse("(print \"hi\")")
DinoParser.parse("(+123.45 'testing parser precedence' TRUE false NIL l33t?)")
DinoParser.parse(<<-STR
""
""
STR
)
DinoParser.parse(<<-STR
12345
+12345
-12345
.34e5
+.34e5
-.34e5
12.34e5
+12.34e5
-12.34e-5
12e345
+12.345
-12.345
STR
)
DinoParser.parse(<<-STR
expression
(expression)
(expression10)
(expression10exp)
(expression10exp?)
STR
)
DinoParser.parse(<<-STR
(class Foo (function bar name (puts name)))
STR
)
DinoParser.parse(<<-STR
(bar (new Foo) "Evan")
STR
)
DinoParser.parse(<<-STR
(class Foo
 (function bar name (
   puts name
 ))
)

(bar (new Foo) "Evan")
STR
)
DinoParser.parse(<<-STR
[( puts "Evan" ) [ 1, 2, 3 ] { "hello" 'world' }]
STR
)
DinoParser.parse(<<-STR
{ 
  "hello" 
  'world' 
}
STR
)
DinoParser.parse(<<-STR
{ 
  "hello" 'world',
  "hello" 'space'
}
STR
)

puts "\n...complete."