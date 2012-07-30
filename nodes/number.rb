class DinoNumber < DinoCore
  {
    "+" => "+",
    "-" => "-",
    "*" => "*",
    "/" => "/",
    "%" => "%",
    "^" => "**"
  }.each do |dino_method, ruby_method|
    add_function(dino_method) do |this, *list|
      list.inject(this) do |memo, value|
        case solution = memo.eval.send(ruby_method, value.eval)
        when Float   then DinoFloat.new(solution)
        when Integer then DinoInt.new(solution)
        else raise solution
        end
      end
    end
  end
end
