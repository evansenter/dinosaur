require "awesome_print"
require "./parser.rb"

Dir[File.join(".", "nodes", "*.rb")].each do |path|
  autoload("Dino" + File.basename(path, ".rb").split(/_/).map { |fragment| fragment.capitalize }.join, path)
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