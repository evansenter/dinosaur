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

# Single character rules
# rule(:lparen)     { str('(') >> space? }
# rule(:rparen)     { str(')') >> space? }
# rule(:comma)      { str(',') >> space? }
# 
# rule(:space)      { match('\s').repeat(1) }
# rule(:space?)     { space.maybe }
# 
# # Things
# rule(:integer)    { match('[0-9]').repeat(1).as(:int) >> space? }
# rule(:identifier) { match['a-z'].repeat(1) }
# rule(:operator)   { match('[+]') >> space? }
#   
# # Grammar parts
# rule(:sum)        { 
#   integer.as(:left) >> operator.as(:op) >> expression.as(:right) }
# rule(:arglist)    { expression >> (comma >> expression).repeat }
# rule(:funcall)    { 
#   identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }
#   
# rule(:expression) { funcall | sum | integer }
# root :expression

class DinoParser < Parslet::Parser
  # White-space
  rule(:terminate) { (non_terminating_space? >> end_of_line >> non_terminating_space?).repeat(1) }
  rule(:end_of_line) { match("\n") }
  rule(:non_terminating_space) { match[" \t"].repeat(1) }
  rule(:non_terminating_space?) { non_terminating_space.maybe }
  
  # Simple
  rule(:characters) { match["A-Za-z"].repeat(1) }
  rule(:characters?) { characters.maybe }
  
  # Numerics
  rule(:sign?) { match["+-"].maybe.as(:sign) }
  rule(:digits) { match["0-9"].repeat(1) }
  rule(:digits?) { digits.maybe }
  rule(:significand) { (digits? >> str(".") >> digits).as(:significand) }
  rule(:exponent?) { (match["eE"] >> digits.as(:exponent)).maybe }
  rule(:integer) { sign? >> digits.as(:value) >> non_terminating_space? }
  rule(:float) { (sign? >> significand >> exponent?).as(:value) >> non_terminating_space? }
  rule(:number) { (float.as(:float) | integer.as(:integer)) >> non_terminating_space? }
  
  # Strings (still needs interpolation)
  rule(:string) { (str(?") >> match['^"'].repeat.as(:body) >> str(?")).as(:string) >> non_terminating_space? }
  
  # Grammar
  rule(:atom) { number | string }
  rule(:function_name) { (characters >> (digits | characters).repeat >> str(??).maybe).as(:name) }
  rule(:function_call) { (function_name).as(:function_call) >> non_terminating_space? }
  rule(:list) { (str(?() >> str(?))).as(:list) >> non_terminating_space? }
  rule(:expression) { non_terminating_space? >> (function_call | atom).as(:expression) }
  rule(:expressions) { ((expression >> terminate).repeat >> expression.maybe).as(:expressions) }

  root(:expressions)
end

pp DinoParser.new.parse("")
pp DinoParser.new.parse("\"\"")
pp DinoParser.new.parse("\"\"\n\"\"")
pp DinoParser.new.parse('"12345"')
pp DinoParser.new.parse("10\n+10\n-10")
pp DinoParser.new.parse("10.0\n+.10\n-1.0e10")
pp DinoParser.new.parse("exp\nexp\nexp\n\nexp\n\n\n")
pp DinoParser.new.parse("exp\nexp10?\nexp\n\nexp")

string = <<-STR
(class Foo
 (function bar [name] (
   puts name
 ))
)

(bar (new Foo) "Evan")
STR

pp DinoParser.new.parse(string)