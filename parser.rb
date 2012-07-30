require "pp"
require "parslet"
require "./utils.rb"

class DinoParser < Parslet::Parser
  class << self; attr_accessor :debug; end
  
  # White-space handlers
  rule(:nts) { match[" \t,"].repeat(1) }
  rule(:nts?) { nts.maybe }
  rule(:eol) { match("\n") }
  # Separator (non-forced, can terminate)
  rule(:separator?) { (nts | eol).repeat }
  # Separator (forced terminate)
  rule(:terminate) { (nts? >> eol >> nts?).repeat(1) }
  
  # Non-whitespace characters
  rule(:dot) { str(?.) }
  rule(:d_quote) { str(?") }
  rule(:s_quote) { str(?') }
  rule(:l_call) { str(?() }
  rule(:r_call) { str(?)) }
  rule(:l_list) { str(?[) }
  rule(:r_list) { str(?]) }
  rule(:l_dict) { str(?{) }
  rule(:r_dict) { str(?}) }
  rule(:math_op) { str("+") | str("-") | str("*") | str("/") | str("%") | str("^") }
  rule(:characters) { match["A-Za-z"].repeat(1) }
  rule(:characters?) { characters.maybe }
  rule(:digits) { match["0-9"].repeat(1) }
  rule(:digits?) { digits.maybe }
  rule(:sign?) { match["+-"].maybe }
  
  # Special tokens
  rule(:true_token) { (str("true") | str("TRUE")).as(:true_token) }
  rule(:false_token) { (str("false") | str("FALSE")).as(:false_token) }
  rule(:nil_token) { (str("nil") | str("NIL")).as(:nil_token) }
  
  # Numbers
  rule(:signed_int) { sign? >> digits }
  rule(:significand) { sign? >> digits? >> dot >> digits }
  rule(:exponent) { match["eE"] >> signed_int.as(:exponent) }
  rule(:exponent?) { exponent.maybe }
  rule(:float) { ((significand.as(:significand) >> exponent?) | (signed_int.as(:significand) >> exponent)).as(:value) }
  rule(:integer) { signed_int.as(:value) }
  rule(:number) { (float.as(:float) | integer.as(:integer)).as(:number) }
  
  # Strings (still needs interpolation)
  rule(:s_string_body) { (s_quote.absnt? >> any).repeat.as(:body) }
  rule(:d_string_body) { (d_quote.absnt? >> any).repeat.as(:body) }
  rule(:s_string) { (s_quote >> s_string_body >> s_quote).as(:string) }
  rule(:d_string) { (d_quote >> d_string_body >> d_quote).as(:string) }
  rule(:string) { (s_string | d_string) }
  
  # Grammar
  rule(:f_name) { (((characters.repeat(1) >> (digits | characters).repeat >> str(??).maybe) | math_op) >> dot.maybe).as(:f_name) }
  rule(:atom) { (number | string | true_token | false_token | nil_token | f_name) }
  rule(:dict) { l_dict >> (separator? >> expression.as(:key) >> separator? >> expression.as(:value) >> separator?).repeat.as(:dict) >> r_dict }
  rule(:list) { l_list >> (separator? >> expression >> separator?).repeat.as(:list) >> r_list }
  rule(:call) { l_call >> (separator? >> expression >> separator?).repeat(1).as(:call) >> r_call }
  rule(:expression) { (call | list | dict | atom) >> nts? }
  rule(:expressions) { (((nts? >> expression >> terminate) | terminate).repeat >> (nts? >> expression).maybe).as(:expressions) }

  root(:expressions)
  
  def self.parse(string, print_parse = false)
    new.parse(string).tap do |parsed_string|
      if debug
        puts "Raw input:\n#{string}\n"
        puts "Parse tree:"
        pp parsed_string
        puts
      end
    end
  end
end