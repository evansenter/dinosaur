require "pp"
require "parslet"

# class Lisp
#   def initialize
#     @env = { 
#       :label => lambda { |(name,val), _| @env[name] = val },
#       :quote => lambda { |sexpr, _| sexpr[0] },
#       :car   => lambda { |(list), _| list[0] },
#       :cdr   => lambda { |(list), _| list.drop 1 },
#       :cons  => lambda { |(e,cell), _| [e] + cell },
#       :eq    => lambda { |(l,r), _| l == r },
#       :if    => lambda { |(cond, thn, els), ctx| eval(cond, ctx) ? eval(thn, ctx) : eval(els, ctx) },
#       :atom  => lambda { |(sexpr), _| (sexpr.is_a? Symbol) or (sexpr.is_a? Numeric) }
#     }
#   end
# 
#   def apply fn, args, ctx=@env
#     return @env[fn].call(args, ctx) if @env[fn].respond_to? :call
# 
#     self.eval @env[fn][2], Hash[*(@env[fn][1].zip args).flatten(1)]
#   end
# 
#   def eval sexpr, ctx=@env
#     if @env[:atom].call [sexpr], ctx
#       return ctx[sexpr] if ctx[sexpr]
#       return sexpr
#     end
# 
#     fn = sexpr[0]
#     args = (sexpr.drop 1)
#     args = args.map { |a| self.eval(a, ctx) } if not [:quote, :if].member? fn
#     apply(fn, args, ctx)
#   end
# end

class DinoParser < Parslet::Parser
  # White-space
  rule(:terminate) { (nts? >> eol >> nts?).repeat(1) }
  rule(:eol) { match("\n") }
  rule(:nts) { match[" \t"].repeat(1) }
  rule(:nts?) { nts.maybe }
  rule(:separator) { (nts | eol).repeat(1) }
  rule(:separator?) { separator.maybe }
  
  # Simple
  rule(:characters) { match["A-Za-z"].repeat(1) }
  rule(:characters?) { characters.maybe }
  
  # Numerics
  rule(:sign?) { match["+-"].maybe.as(:sign) }
  rule(:digits) { match["0-9"].repeat(1) }
  rule(:digits?) { digits.maybe }
  rule(:significand) { (digits? >> str(".") >> digits).as(:significand) }
  rule(:exponent?) { (match["eE"] >> digits.as(:exponent)).maybe }
  rule(:integer) { sign? >> digits.as(:value) >> nts? }
  rule(:float) { (sign? >> significand >> exponent?).as(:value) >> nts? }
  rule(:number) { (float.as(:float) | integer.as(:integer)) >> nts? }
  
  # Strings (still needs interpolation)
  rule(:string) { (str(?") >> (str(?").absnt? >> any).repeat.as(:body) >> str(?")).as(:string) >> nts? }
  
  # Grammar
  rule(:function_name) { (characters >> (digits | characters).repeat >> str(??).maybe).as(:function_name) }
  rule(:atom) { function_name | number | string }
  rule(:list) { str(?() >> (separator? >> expression >> separator?).repeat.as(:list) >> str(?)) >> nts? }
  rule(:expression) { (list | function_name | atom).as(:expression) }
  rule(:expressions) { (((nts? >> expression >> terminate) | terminate).repeat >> (nts? >> expression).maybe).as(:expressions) }

  root(:expressions)
  
  def self.parse(string)
    begin
      puts string
      
      new.parse(string).tap do |parsed_string|
        pp parsed_string
        puts
      end
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
      raise failure
    end
  end
end

DinoParser.parse("")

DinoParser.parse("\"\"")

DinoParser.parse("\"12345\"")

DinoParser.parse("(12345)")

DinoParser.parse("hello")

DinoParser.parse("(hello)")

DinoParser.parse("( hello )")

DinoParser.parse(" ( hello ) ")

DinoParser.parse("\n ( \n hello \n ) \n ")

DinoParser.parse("\n ( \n hello (world) \n ) \n ")

DinoParser.parse("(print \"hi\")")

DinoParser.parse(<<-STR
""
""
STR
)

DinoParser.parse(<<-STR
12345
+12345
-12345
12.34e5
+12.34e5
-12.34e5
12.345
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