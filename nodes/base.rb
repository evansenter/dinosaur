class DinoBase < DinoCore
  class << self; attr_accessor :context; end
  attr_reader :expressions
  
  def initialize(expressions)
    @expressions       = expressions
    self.class.context = self
  end
  
  add_function("p") do |*arguments|
    pp(*arguments.map(&:eval))
    DinoNil
  end
  
  def eval
    until expressions.empty?
      result = expressions.shift.eval
    end
    
    result
  end
end
