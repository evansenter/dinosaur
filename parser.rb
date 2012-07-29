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
  rule(:terminate) { (non_terminating_space? >> end_of_line >> non_terminating_space?).repeat(1) }
  rule(:end_of_line) { match("\n").repeat(1) }
  rule(:end_of_line?) { end_of_line.maybe }
  rule(:non_terminating_space) { match[" \t"].repeat(1) }
  rule(:non_terminating_space?) { non_terminating_space.maybe }
  
  rule(:integer) { match["0-9"].repeat(1).as(:integer) >> non_terminating_space? }
  rule(:atom) { integer }
  
  rule(:expression) { non_terminating_space? >> (str("exp") | atom).as(:expression) }
  rule(:expressions) { ((expression >> terminate).repeat >> expression.maybe).as(:expressions) }

  root(:expressions)
end

pp DinoParser.new.parse("")
pp DinoParser.new.parse("  \t12\n\n  ")
pp DinoParser.new.parse("exp\nexp\nexp\n\nexp\n\n\n")
pp DinoParser.new.parse("exp\nexp\nexp\n\nexp")