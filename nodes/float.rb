class DinoFloat < DinoNumber
  init_with_value
  
  def eval
    @eval ||= value.to_f
  end
end
